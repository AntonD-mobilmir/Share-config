;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

boardID := "5732cc3d0a8bee805cab7f11" ; Учёт системных блоков
dumpFName = %A_ScriptDir%\..\actual\computer-accounting.json

#include %A_LineFile%\..\..\..\config\_Scripts\Lib\find7zexe.ahk

If (TrelloAPI1("GET", "/boards/" . boardID . "/cards", boardDump)) {
    FileDelete "%dumpFName%.7z"
    FileAppend %boardDump%, %dumpFName%
    Run %exe7z% a -mx=9 "%dumpFName%.7z" "%dumpFName%"
    ExitApp %ErrorLevel%
}

ExitApp 1

#include %A_LineFile%\..\..\..\config\_Scripts\Lib\TrelloAPI1.ahk
