;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

pathTrelloID=%A_AppDataCommon%\mobilmir.ru\trello-id.txt

argc = %0%
If (argc) {
    errtxt=
    Loop %argc%
    {
	If (FileExist(%A_Index%))
	    Run % """" %A_Index% """"
	Else
	    errtxt .= %A_Index% " "
    }
}
If (errtxt || !FileExist(pathTrelloID)) {
    MsgBox Файл "%pathTrelloID%" не записан.`nИсправьте карточку`, обновите дамп Inventory\collector-script\trello-accounting-board-dump (или дождитесь автоматического обновления) и снова запустите на этом компьютере "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Write-trello-id.ahk"
    ExitApp
}

cardText=
Loop Read, %pathTrelloID%
{
    If (A_Index==3)
	cardTitle := A_LoopReadLine
    Else If (A_Index==1)
	cardURL := CutTrelloCardURL(A_LoopReadLine)
    Else If (A_Index==2)
	cardHostname := A_LoopReadLine
    Else
	cardText .= A_LoopReadLine "`n"
} Until A_Index >= 4
Loop
    Sleep 200
Until A_TimeIdlePhysical > 100
Progress zh0, %cardText%`n`n[F1] – открыть %cardURL%`n[F2] – открыть trello-id.txt, %cardTitle%, %cardHostname%
Loop
    Sleep 200
Until A_TimeIdlePhysical < 200
Progress Off
Sleep 200

If (runURL)
    Run %cardURL%
If (openFile)
    Run %pathTrelloID%

ExitApp

F1:: runURL := 1
F2:: openFile := 1

#include %A_ScriptDir%\..\Lib\CutTrelloCardURL.ahk
