;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

cards := JSONLoadFromFile(A_ScriptDir "\..\trello-accounting\board-dump\computer-accounting.json")

ColFuncs := [ Func("GetListName"), Func("GetLabels"), Func("GetUrlWithShortId") ]
Cols := [ 1, "name", 3, "closed", 2 ]

out := "Список" A_Tab "Название" A_Tab "Ссылка" A_Tab "Заархивирована" A_Tab "Метки"

For i, card in cards {
    out .= "`n"
    Loop % Cols.Length()
    {
	tcol := Cols[A_Index]
	If tcol is integer
	    vcol := ColFuncs[tcol].Call(card)
	Else
	    vcol := card[tcol]
	out .= vcol A_Tab
    }
}

fnameout = %A_Temp%\%A_ScriptName%.%A_Now%.tsv
FileAppend %out%, %fnameout%
Try
    Run "%fnameout%"
Catch e
    Run explorer.exe /select`,"%fnameout%"

ExitApp

GetListName(card) {
    static listNames := ""
    If (!IsObject(listNames)) {
	lists := JSONLoadFromFile(A_ScriptDir "\..\trello-accounting\board-dump\lists.json")
	listNames := {}
	For i, list in lists
	    listNames[list.id] := list.name
    }

    return listNames[card.idList]
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

#include <JSON>
