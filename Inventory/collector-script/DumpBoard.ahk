;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

boardID := "5732cc3d0a8bee805cab7f11" ; Учёт системных блоков
dumpDir = %A_ScriptDir%\trello-accounting-board-dump

#include %A_LineFile%\..\..\..\config\_Scripts\Lib\find7zexe.ahk

Try {
    For dumpFName, request in {"computer-accounting": "/cards"
			    , "lists": "/lists"}
	If (TrelloAPI1("GET", "/boards/" . boardID . request, jsonDump)) {
	    If (IsObject(fout := FileOpen(dumpDir "\" dumpFName ".new", "w")) && fout.Write(jsonDump), fout.Close()) {
		thisFile = %dumpFName%.json
		FileMove %dumpDir%\%dumpFName%.new, %dumpDir%\%thisFile%, 1
		arcFiles .= " """ thisFile """"
	    }
	}
    RunWait %exe7z% a -mx=9 -- "dump.7z.new" %arcFiles%, %dumpDir%, Min UseErrorLevel
    If (ErrorLevel)
	ExitApp %ErrorLevel%
    Else
	FileMove %dumpDir%\dump.7z.new, %dumpDir%\dump.7z, 1
} Catch
    ExitApp 1

#include %A_LineFile%\..\..\..\config\_Scripts\Lib\TrelloAPI1.ahk
