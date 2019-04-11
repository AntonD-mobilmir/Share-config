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

actionsToLog := { "updateCard": Func("parse_updateCard")
                , "commentCard": {"Добавлен комментарий": "data.text"}
                , "createCard": "Карточка создана"
                , "convertToCardFromCheckItem": "Пункт чек-листа преобразован в карточку"
                , "updateCheckItemStateOnCard": {"Изменена отметка пункта": "data.checkItem.state data.checkItem.name data.checkItem.textData"}
                , "addMemberToCard": {"На карточку добавлен участник": "data.member.name"}
                , "removeMemberFromCard": {"С карточки удален участник": "data.member.name"}
                , "addChecklistToCard": {"Добавлен чек-лист": "data.checklist.name"}
                , "removeChecklistFromCard": {"Удален чек-лист": "data.checklist.name"}
                , "updateChecklist": "Измненен чек-лист"
                , "addAttachmentToCard": "Прикреплено вложение"
                , "deleteAttachmentFromCard": "Удалено вложение"
                , "moveCardFromBoard": "Карточка перемещена с доски"
                , "moveCardToBoard": "Карточка перемещена на эту доску"
                , "deleteCard": "Карточка удалена"
                , "copyCard": "Карточка скопирована" }

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
        actions.Push(actn)
        cardMembers := BatchQueryCardMembers(actn.data.card.id, cardMembers)
    }
} Until !maxIndex
cardMembers := BatchQueryCardMembers("", cardMembers)
flog.Close()

FileAppend % ObjectToText(cardMembers), %A_Temp%\%A_ScriptName%.debug.txt

out =
    (Join, LTrim
    "Дата"
    "Карточка"
    "Заголовок карточки"
    "Кому назначена"
    "Доска"
    "Список"
    "Пользователь, выполнивший действие"
    "Действие с карточкой"
    "Подробности"
    "JSON"
    `n
    )
For i, actn in actions {
    If (actionsToLog.HasKey(actn.type)) {
        logActnData := actionsToLog[actn.type]
        If (IsFunc(logActnData))
            logActnData := logActnData.Call(actn.data)
        Else If (IsObject(logActnData)) {
            logActnDetails := {}
            For logActnDataName, logActnDataQuery in logActnData {
                logDetailText := "", lpos := 1
                Loop Parse, logActnDataQuery, %A_Space%`,
                {
                    logActnDataObj := actn
                    Loop Parse, A_LoopField,.
                        logActnDataObj := logActnDataObj[A_LoopField]
                    logDetailText .= logActnDataObj . SubStr(logActnDataQuery, lpos += StrLen(A_LoopField), 1)
                }
                logActnDetails[logActnDataName] := logDetailText
            }
            logActnData := logActnDetails
        } Else
            logActnData := {(logActnData): ""}
    } Else {
        logActnData := {"Неизвестное действие": ""}
    }
    
    For updType, detail in logActnData { ; при изменении списка, в data.list.name пусто
        out .= actn.date 
             . ",""https://trello.com/c/" actn.data.card.shortLink
             . """,""" StrReplace(actn.data.card.name, """", """""")
             . """,""" StrReplace(cardMembers[actn.data.card.id], """", """""")
             . """,""" StrReplace(actn.data.board.name, """", """""")
             . """,""" StrReplace(((listName := actn.data.list.name) = "" ? actn.data.listAfter.name : listName), """", """""")
             . """,""" StrReplace(actn.memberCreator.fullName " (@" actn.memberCreator.username ")" , """", """""")
             . """,""" StrReplace(updType, """", """""")
             . """,""" StrReplace(detail, """", """""")
             . """,""" StrReplace(JSON.Dump(actn) , """", """""")
             . """`n"
    }
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
    changeList := {}
    
    For field, value in data.old {
	If field in desc,due,pos,name,idLabels,idAttachmentCover,idMembers
	    continue
	Else If (field == "dueComplete")
            changeList[(value ? "☐" : "☑") . " в поле ""срок"""] := "было: " value ; value – это старое значение, а не новое
        Else If (field == "closed")
            changeList[(value ? "раз" : "за") "архивирована"] := "было: " value
	Else If (field == "idList") {
            newListName := data.listAfter.name
            changeList["Перемещена в список"] := newListName
            ;If newListName in Готово,Выполнено,Завершено
	} Else {
	    changeList["Поле " field " изменено со значения "] := value
        }
    }
    If (changeList.Length())
        return changeList
}

#include <TrelloAPI1>
