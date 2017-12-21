;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

FileRead jsoncards, %A_ScriptDir%\..\trello-accounting\board-dump\computer-accounting.json
cards := JSON.Load(jsoncards)
jsoncards=
FileRead jsonlists, %A_ScriptDir%\..\trello-accounting\board-dump\lists.json
lists := JSON.Load(jsonlists)
jsonlists=

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
Run %fnameout%

#include <JSON>
