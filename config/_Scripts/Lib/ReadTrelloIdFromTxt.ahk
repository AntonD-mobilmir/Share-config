;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.

ReadTrelloIdFromTxt(ByRef verifyHostname := "") {
    pathTrelloID := A_AppDataCommon "\mobilmir.ru\trello-id.txt"
    , trelloidlines := ["url", "Hostname", "name", "id", "List"]
    
    TrelloIdTxt := {}
    Loop Read, %A_AppDataCommon%\mobilmir.ru\trello-id.txt
	If (A_LoopReadLine && varName := trelloidlines[A_Index])
	    TrelloIdTxt[varName] := A_LoopReadLine
    Until A_Index > trelloidlines.Length()
    
    If (verifyHostname && outObject.trelloHostname && outObject.trelloHostname != verifyHostname)
	verifyHostname .= " (trello-id.txt: " outObject.trelloHostname ")"

    return TrelloIdTxt
}
