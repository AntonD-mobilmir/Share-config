;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv

; queryPrefix := "/members/me"
TrelloActionsLogToFile(queryPrefix, actionsToLog := "", timeOffset := "", reportName := "") {
    global cardMembers
    GetTrelloAuthToken(,, "read", "TrelloActionsLogToFile.ahk")
    If (!actionsToLog)
        actionsToLog := {"updateCard": "parse_updateCard"} ; "updateCheckItemStateOnCard": ""
    
    If (timeOffset == "")
        timeOffset := {"SubMonths": 1, 6: "01"}
    
    If (IsObject(timeOffset)) {
        actions_since := A_Now
        For fn, amount in timeOffset
            If fn is not Integer
                actions_since := Func(fn).Call(actions_since, amount)
        For offset, replacement in timeOffset
            If offset is Integer
                actions_since := SubStr(actions_since, 1, offset) . replacement . SubStr(actions_since, offset + 1 + StrLen(replacement))
    } Else
        actions_since := timeOffset

    FormatTime actions_since, %actions_since%, yyyy-MM-dd
    MsgBox %actions_since%
    
    ;actions_since := SubStr(A_Now, 1, 6) "01" ; YYYYMM01 – первое число текущего месяца
    ;actions_since += -1, Days ; последнее число предыдущего
    ;actions_since := SubStr(actions_since, 1, 4) "-" SubStr(actions_since, 5, 2) "-01" ; YYYY-MM-01 – первое число предыдущего в формате ISO
    
    If (!IsObject(flog := FileOpen(fnameLog := A_Temp "\" A_ScriptName ".queries-responces.log", "w")))
        Throw Exception("Error " A_LastError " opening file",, fnameLog)
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
    
    FileAppend % ObjectToText(cardMembers), %A_Temp%\%A_LineFile%.debug.txt
    
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
    
    If (!reportName)
        reportName = %A_TEMP%\%A_ScriptName%-%A_Now%.tsv
    FileAppend %out%, %reportName%
    Try
        Run "%reportName%"
    Catch e
        Run explorer.exe /select`,"%reportName%"
    return reportName
}

SubMonths(src, amount) {
    out := src
    Loop %amount%
    {
        out := SubStr(out, 1, 6) "01" ; YYYYMM01 – первое число текущего месяца
        out += -1, Days ; последнее число предыдущего месяца
    }
    return SubStr(out, 1, 6) . SubStr(src, 7) ; предыдущий месяц минус один, тот же день месяца
}

#include %A_LineFile%\..\parse_updateCard.ahk
#include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\TrelloAPI1.ahk
