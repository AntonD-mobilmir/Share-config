;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#Warn
#Warn LocalSameAsGlobal, Off
FileEncoding UTF-8
VarsWithTrelloRequests := { cards: "cards"
			  , lists: "lists" }

Loop %0%
{
    argv := %A_Index%  ; path to dump OR board ID
    cards=
    
    If (!FileExist(argv)) {
	dumpsDir = %A_ScriptDir%\cache
	FileCreateDir %dumpsDir%
	pathBoardDmp := dumpsDir "\" argv "-board.json"
	savedActionDate := JSONLoadFromFile(pathBoardDmp).lastActionDate
	
	If (savedActionDate == (lastActionDate := TrelloAPI1("GET", "/boards/" . argv "/actions?limit=1&fields=date", jsonActions := Object())[1].date)) {
	    For varName in VarsWithTrelloRequests
		%varName% := JSONLoadFromFile(dumpsDir "\" argv "-" varName ".json")
	} Else {
	    ;MsgBox % "savedActionDate: " savedActionDate "`nlastActionDate: " lastActionDate "`n" jsonActions
	    
	    If (board := TrelloAPI1("GET", "/boards/" . argv, Object())) {
		board.lastActionDate := lastActionDate
		TransactWriteFile(board, pathBoardDmp)
	    }
	    
	    For varName, request in VarsWithTrelloRequests
		If (%varName% := TrelloAPI1("GET", "/boards/" argv "/" request, jsonDump := Object()))
		    TransactWriteFile(jsonDump, dumpsDir "\" argv "-" varName ".json")
	}
    }
    
    If (!IsObject(cards)) {
	SplitPath argv, filenameDump, dirDump, extensionDump, nameNoExtDump, driveDump
	cards := JSONLoadFromFile(argv)
	If (SubStr(nameNoExtDump, -5) == "-cards") ; 0 is last character, -1 are two last, etc
	    nameNoExtDump := SubStr(nameNoExtDump, 1, -6) ; omit 6 chars from end of string
	lists := JSONLoadFromFile(dirDump "\" nameNoExtDump "-lists.json")
    }
    
    listNames := {}
    For i, list in lists
	listNames[list.id] := list.name

    Cols := [ 1, "name", "shortUrl", "idShort" ]

    out =
    Loop % Cols.Length()
	out .= Cols[A_Index] A_Tab

    For i, card in cards {
	Loop % Cols.Length()
	{
	    tcol := Cols[A_Index]
	    If (tcol == 1)
		vcol := listNames[card.idList]
	    Else
		vcol := card[tcol]
	    out .= vcol A_Tab
	}
	out .= "`n"
    }

    fnameout = %A_Temp%\%A_ScriptName%.%A_Now%.tsv
    FileAppend %out%, %fnameout%
}
ExitApp

TransactWriteFile(ByRef data, ByRef path) {
    If (IsObject(fout := FileOpen(path ".new", "w")) && fout.Write(IsObject(data) ? JSON.Dump(data) : data), fout.Close())
	FileMove %path%.tmp, %path%, 1
}

JSONLoadFromFile(ByRef path) {
    Try {
	FileRead jsondata, %path%
	return JSON.Load(jsondata)
    }
}

#include <JSON>
