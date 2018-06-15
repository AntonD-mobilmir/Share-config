;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

boardID := "5732cc3d0a8bee805cab7f11" ; Учёт системных блоков
dumpDir = %A_ScriptDir%\..\trello-accounting\board-dump
olddumpsDir = %A_ScriptDir%\..\old\board-dumps
FileCreateDir %olddumpsDir%

#include %A_LineFile%\..\..\..\config\_Scripts\Lib\find7zexe.ahk

Try {
    FileRead jsonsavedBoard, %dumpDir%\board.json
    savedBoard := JSON.Load(jsonsavedBoard)
    savedActionDate := savedBoard.lastActionDate
}
Try {
    If (savedActionDate != (lastActionDate := TrelloAPI1("GET", "/boards/" boardID "/actions?limit=1&fields=date", jsonActions := Object())[1].date)) {
	If (board := TrelloAPI1("GET", "/boards/" boardID, Object())) {
	    board.lastActionDate := lastActionDate
	    If (IsObject(fout := FileOpen(dumpDir "\board.json.new", "w")) && fout.Write(JSON.Dump(board)), fout.Close())
		FileMove %dumpDir%\board.json.new, %dumpDir%\board.json, 1
	}
	
	For dumpFName, request in { "computer-accounting": "/cards"
				  , "lists": "/lists" }
	    If (TrelloAPI1("GET", "/boards/" . boardID . request, jsonDump)) {
		fnameCurDmp := dumpFName ".json"
		arcFiles .= " """ fnameCurDmp """"
		Try FileRead lastDump, %dumpDir%\%fnameCurDmp%
		If (!(lastDump == jsonDump)) {
		    If (IsObject(fout := FileOpen(dumpDir "\" dumpFName ".new", "w")) && fout.Write(jsonDump), fout.Close()) {
			Loop Files, %dumpDir%\%fnameCurDmp%
			    FileMove %A_LoopFileFullPath%, % olddumpsDir "\" SubStr(A_LoopFileName, 1, -StrLen(A_LoopFileExt)) . A_LoopFileTimeModified "." A_LoopFileExt, 1
			FileMove %dumpDir%\%dumpFName%.new, %dumpDir%\%fnameCurDmp%, 1
		    }
		}
	    }
	Try FileDelete %dumpDir%\dump.7z.new
	RunWait %exe7z% a -mx=9 -- "%dumpDir%\dump.7z.new" %arcFiles%, %dumpDir%, Min UseErrorLevel
	If (ErrorLevel)
	    ExitApp %ErrorLevel%
	Else
	    FileMove %dumpDir%\dump.7z.new, %dumpDir%\dump.7z, 1
    }
} Catch e {
    If (!IsObject(e))
	e := {Extra: e}
    e.debug := debug
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    If (RunInteractiveInstalls=="1")
	Throw e
    ExitApp 1
}

#include %A_LineFile%\..\..\..\config\_Scripts\Lib\ObjectToText.ahk
#include %A_LineFile%\..\..\..\config\_Scripts\Lib\TrelloAPI1.ahk
