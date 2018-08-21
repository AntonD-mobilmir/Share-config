;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
EnvGet UserProfile, UserProfile

GetTrelloAuthToken(,, "read", A_Scriptname)

queryPrefix := A_Args[1]
If (!queryPrefix)
    queryPrefix := "/boards/GNhOgPCn"

actionsToLog := { "updateCard": "parse_updateCard"
                , "commentCard": "parse_commentCard"
                , "createCard": "Карточка создана"
                , "updateCheckItemStateOnCard": ""
                , "addMemberToCard": "На карточку добавлен участник"
                , "addChecklistToCard": "Добавлен чек-лист"
                , "copyCard": "Карточка скопирована"
                , "updateCheckItemStateOnCard": "В чек-листе отмечен пункт" }

actions_since := SubStr(A_Now, 1, 6) "01" ; YYYYMM01 – первое число текущего месяца
actions_since += -1, Days ; последнее число предыдущего
actions_since := SubStr(actions_since, 1, 4) "-" SubStr(actions_since, 5, 2) "-01" ; YYYYMM01 – первое число предыдущего

flog := FileOpen(A_Temp "\" A_ScriptName ".queries-responces.log", "w")
lastID := prevLastID := "", actions := [], cardMembers := {}
Loop
{
    maxIndex := 0
    actionsPage := TrelloAPI1("GET", query := queryPrefix "/actions/?action_member=true&actions_limit=100&since=" actions_since . (lastID ? "&before=" lastID : ""), lastresp := Object())
    flog.WriteLine(query " → " lastresp)
    
    For i, actn in actionsPage {
	If (i > maxIndex)
	    maxIndex := i, lastID := actn.id
        If (actionsToLog.HasKey(actn.type))
            actions.Push(actn)
        Else {
            actn[""] := "Неизвестное действие: " actn.type
            actions.Push(actn)
        }
        cardMembers := BatchQueryCardMembers(actn.data.card.id, cardMembers)
    }
} Until !maxIndex
cardMembers := BatchQueryCardMembers("", cardMembers)
flog.Close()

FileAppend % ObjectToText(cardMembers), %A_Temp%\%A_ScriptName%.debug.txt

out := """Дата"",""Карточка"",""Заголовок карточки"",""Кому назначена"",""Доска"",""Список"",""Пользователь, выполнивший действие"",""Действие с карточкой""`n"
For i, actn in actions {
    If (IsFunc(fnName := actionsToLog[actn.type]))
        curLn := Func(fnName).Call(actn.data)
    Else
        curLn := fnName ": " JSON.Dump(actn)
    If (!curLn)
        continue
    ; при изменении списка, в data.list.name пусто
    out .= actn.date 
         . ",""https://trello.com/c/" actn.data.card.shortLink
         . """,""" StrReplace(actn.data.card.name, """", """""")
         . """,""" StrReplace(cardMembers[actn.data.card.id], """", """""")
         . """,""" StrReplace(actn.data.board.name, """", """""")
         . """,""" StrReplace(((listName := actn.data.list.name) = "" ? actn.data.listAfter.name : listName), """", """""")
         . """,""" StrReplace(actn.memberCreator.fullName "(@" actn.memberCreator.username ")" , """", """""")
         . """,""" StrReplace(curLn , """", """""")
         . """`n"
}

reportName = %A_TEMP%\%A_ScriptName%-%A_Now%.csv
FileAppend %out%, %reportName%
Try
    Run "%reportName%"
Catch e
    Run explorer.exe /select`,"%reportName%"
ExitApp

BatchQueryCardMembers(idCard, cardMembers) {
    global flog
    static BatchQueries := 10, countQueries := 0, queryList := {}
    If (idCard && !queryList.HasKey(idCard) && !memberList.HasKey(idCard))
        queryList[idCard] := "", countQueries++
    If (countQueries = BatchQueries || (countQueries && !idCard)) {
        queryStr := "/batch/?urls=", queryOrder := []
        For idCard in queryList
            queryOrder[A_Index] := idCard, queryStr .= "/cards/" idCard "/members,"
        For i, batchResponse in TrelloAPI1("GET", query := SubStr(queryStr, 1, -1), lastResp := {})
            For statusCode, members in batchResponse
                For j, member in members
                    cardMembers[queryOrder[i]] := member.fullName " @" member.username
        flog.WriteLine(query " → " lastresp)
        
        countQueries := 0, queryList := {}
    }
    
    return cardMembers
}

parse_updateCard(data) {
    global cardMembers
    changeList := ""
    For field, value in data.old
	If field in desc,due,pos,name,idLabels,idAttachmentCover,idMembers
	    continue
	Else If (field == "dueComplete")
            changeList .= (value ? "☐" : "☑") . " в поле ""срок"", " ; value – это старое значение, а не новое
        Else If (field == "closed")
            changeList .= (value ? "раз" : "за") "архивирована, "
	Else If (field == "idList") {
            newListName := data.listAfter.name
            If newListName in Готово,Выполнено,Завершено
		changeList .= "перемещена в список " data.listAfter.name ", "
	} Else
	    return "Изменено поле """ field """, обработка для него не прописана. Всё действие: " JSON.Dump(data)
    If (changeList)
        return SubStr(changeList, 1, -2)
}

parse_commentCard(data) {
    return "Добавлен комментарий: " data.text
}

#include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\TrelloAPI1.ahk
