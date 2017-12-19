;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
logFile = %A_Temp%\%A_ScriptName%.%A_Now%.txt

FieldsToCompare := {"desc": "?desc="}

Try {
    RunWait "%A_AhkPath%" "%A_ScriptDir%\DumpBoard.ahk"
    FileRead jsoncards, %A_ScriptDir%\..\trello-accounting\board-dump\computer-accounting.json
    cards := JSON.Load(jsoncards)
    
    For i, card in cards {
	origCard := card.Clone()
	If (newCard := CheckUpdate(card)) {
	    For field, param in FieldsToCompare
		If (newCard.HasKey(field) && !(newCard[field] == origCard[field])) {
		    ;MsgBox % "Updating " field " on " origCard.name " <" origCard.shortURL ">"
		    If (!TrelloAPI1("PUT", "/cards/" origCard.id param UriEncode(newCard[field]), r := ""))
			Throw Exception(r)
		}
	}
    }
    ExitApp 0
} Catch e {
    MsgBox % ObjectToText(e)
}
ExitApp -1

CheckUpdate(ByRef card) {
    desc := card.desc
    If (InStr(desc, "BSN12345678901234567")) { ; "MB SerialNumber":"BSN12345678901234567"
	desc := RegexReplace(desc, "((, )?SerialNumber: )?BSN12345678901234567")
    }

    If (InStr(desc, "00000000")) { ; RAM: 8502, PartNumber: 1600LL Series, SerialNumber: 00000000
	desc := StrReplace(desc, ", SerialNumber: 00000000")
	desc := StrReplace(desc, "SerialNumber: 00000000")
	desc := RegexReplace(desc, "\b00000000(\b)", "$1")
    }
    
    If (InStr(desc, "20:41:53:59:4E:FF")) ; Виртуальный NIC, удалять всю строку
	desc := RegexReplace(desc, "\nNIC:[^\n]*(20:41:53:59:4E:FF|RAS Async Adapter)[^\n]*\n+", "\n")
    
    If (desc != card.desc)
	return {desc: desc}
}

#include <JSON>
