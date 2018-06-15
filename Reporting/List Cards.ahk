;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv
FileEncoding UTF-8
GetTrelloAuthToken(,, "read", A_Scriptname)
flog := FileOpen(A_Temp "\" A_ScriptName ".queries-responces.log", "w")

boardID := A_Args[1]
filter := A_Args[2]
If (!filter) ; https://developers.trello.com/reference/#cards-nested-resource
    filter := "all"
;all
;closed
;none
;open - Includes cards that are open in lists that have been archived.
;visible - Only returns cards in lists that are not closed.

listNames := members := {}
For i, member in TrelloAPI1("GET", query := "/boards/" boardID "/members", lastresp := {})
    members[member.id] := member.fullName " @" member.username
flog.WriteLine(query " → " lastresp)

For i, list in TrelloAPI1("GET", query := "/boards/" boardID "/lists", lastresp := {})
    listNames[list.id] := list.name
flog.WriteLine(query " → " lastresp)

Cols := [ Func("GetListName"), Func("GetUrlWithShortId"), "name", "closed", Func("GetMembers"), "dateLastActivity", "due", Func("GetLabels") ]
out := "Список" A_Tab "URL" A_Tab "Название" A_Tab "Заархивирована" A_Tab "Кому назначена" A_Tab "Последняя активность" A_Tab "Срок" A_Tab "Метки" "`n"

;ToDo: pagination
;lastCardID := ""
;Loop
;{
;    maxIndex := i := card := ""
    querySuffix := (lastCardID ? "&before=" lastCardID : "")
    For i, card in TrelloAPI1("GET", query := "/boards/" boardID "?cards=" filter (querySuffix ? "&" querySuffix : ""), lastresp := {}).cards {
        For k, tcol in Cols {
            If IsFunc(tcol)
                vcol := tcol.Call(card)
            Else
                vcol := card[tcol]
            out .= vcol A_Tab
        }
        out .= "`n"
    }
;    maxIndex := i, lastCardID := card.id
    flog.WriteLine(query " → " lastresp)
;} Until !maxIndex
flog.Close()
reportName = %A_TEMP%\%A_ScriptName%-%A_Now%.tsv
FileAppend %out%, %reportName%

Try
    Run "%reportName%"
Catch e
    Run explorer.exe /select`,"%reportName%"
ExitApp

GetListName(card) {
    global listNames
    return listNames[card.idList]
}

GetMembers(card) {
    global members
    For i, idMember in card.idMembers
        out .= members[idMember] ", "
    return SubStr(out, 1, -2)
}

GetLabels(card) {
    out := ""
    For i, objlabel in card.labels
	out .= objlabel.name ", "
    return SubStr(out, 1, -2)
}

GetUrlWithShortId(card) {
    return card.shortUrl "/" card.idShort
}

JSONLoadFromFile(ByRef path) {
    Try {
	FileRead fjson, %path%
	
	o := JSON.Load(fjson)
	If (!IsObject(o))
	    Throw Exception("Cannot read file as json",, path)
	return o
    } Catch e
	Throw e
}

#include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\TrelloAPI1.ahk
