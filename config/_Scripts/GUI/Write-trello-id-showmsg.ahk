;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

Loop Files, %A_LineFile%\..\..\Write-trello-id.ahk
    pathWtiScript := A_LoopFileLongPath
If (!pathWtiScript)
    pathWtiScript := "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Write-trello-id.ahk"

pathTrelloID=%A_AppDataCommon%\mobilmir.ru\trello-id.txt
errTextSuffix=`n`nИсправьте карточку`, обновите дамп доски (или дождитесь автоматического обновления) и снова запустите на этом компьютере "%pathWtiScript%"

Loop %0%
{
    argv := %A_Index%
    CheckRun(FileExist(argv) && argv != pathTrelloID, argv) || errtxt .= argv " "
}

If (errtxt)
    MsgBox %errtxt%%errTextSuffix%
If (!FileExist(pathTrelloID)) {
    If (!errtxt)
	MsgBox Файл "%pathTrelloID%" не записан.%errTextSuffix%
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

Progress zh0 M, %cardText%`n`n[F1] Открыть %cardURL%`n[F2] Открыть trello-id.txt`nЧтобы закрыть окно`, подвиньте мышку после секундной паузы, %cardTitle%, %cardHostname%
lastHotkeyTime := A_TickCount
Loop
    Sleep 250
Until A_TimeIdlePhysical > 500 ; ожидание простоя
Loop
    Sleep 200
Until A_TimeIdlePhysical < 200 ; ожидание любого действия пользователя

While (CheckRun(openURL, cardURL) || CheckRun(openFile, pathTrelloID) || (A_TickCount - lastHotkeyTime) < 1000) {
    Sleep 200
} ; в течение 1 с после нажатия клавиши, можно нажать ещё раз
Progress Off
ExitApp

CheckRun(ByRef val, ByRef exec) {
    If (val && exec) {
	ToolTip Открывается "%exec%"
	Run "%exec%"
	val := 0
	return 1
    }
}

F1:: openURL := 1, lastHotkeyTime := A_TickCount
F2:: openFile := 1, lastHotkeyTime := A_TickCount
GuiEscape:
GuiClose:
    Sleep 200
    ExitApp

#include %A_ScriptDir%\..\Lib\CutTrelloCardURL.ahk
