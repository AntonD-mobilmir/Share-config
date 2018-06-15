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
    queryPrefix := "/members/me"

actionsToLog := {"updateCard": "parse_updateCard"} ; "updateCheckItemStateOnCard": ""

actions_since := SubStr(A_Now, 1, 6) "01" ; YYYYMM01 – первое число текущего месяца
actions_since += -1, Days ; последнее число предыдущего
actions_since := SubStr(actions_since, 1, 4) "-" SubStr(actions_since, 5, 2) "-01" ; YYYYMM01 – первое число предыдущего

flog := FileOpen(A_Temp "\" A_ScriptName ".queries-responces.log", "w")
lastID := prevLastID := "", actions := [], cardMembers := {}
Loop
{
    maxIndex := 0
    actionsPage := TrelloAPI1("GET", query := queryPrefix "/actions/?action_memberCreator=false&action_member=true&actions_limit=1000&since=" actions_since . (lastID ? "&before=" lastID : ""), lastresp := Object())
    flog.WriteLine(query " → " lastresp)
    
    For i, actn in actionsPage {
	If (i > maxIndex)
	    maxIndex := i, lastID := actn.id
        If (actionsToLog.HasKey(actn.type))
            actions.Push(actn)
        cardMembers := BatchQueryCardMembers(actn.data.card.id, cardMembers)
    }
} Until !maxIndex
cardMembers := BatchQueryCardMembers("", cardMembers)
flog.Close()

FileAppend % ObjectToText(cardMembers), %A_Temp%\%A_ScriptName%.debug.txt

out := "Дата" A_Tab "Карточка" A_Tab "Доска" A_Tab "Список" A_Tab "Заголовок карточки" A_Tab "Кому назначена" A_Tab "Действие с карточкой" "`n"
For i, actn in actions {
    If (IsFunc(fnName := actionsToLog[actn.type]))
        curLn := Func(fnName).Call(actn.data)
    Else
        curLn := JSON.Dump(actn) "`t"
    If (!curLn)
        continue
    out .= actn.date "`thttps://trello.com/c/" actn.data.card.shortLink "`t" curLn "`n"
}

reportName = %A_TEMP%\%A_ScriptName%-%A_Now%.tsv
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
    changeList := "", listName := data.list.name
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
            If (!listName) ; при изменении списка, в data.list.name пусто
                listName := data.listAfter.name
	} Else
	    return "Изменено поле """ field """, обработка для него не прописана. Всё действие: " JSON.Dump(data)
    If (changeList)
        return data.board.name A_Tab listName A_Tab data.card.name A_Tab cardMembers[data.card.id] A_Tab SubStr(changeList, 1, -2)
}

#include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\TrelloAPI1.ahk
