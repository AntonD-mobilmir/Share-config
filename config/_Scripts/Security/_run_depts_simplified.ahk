;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance ignore

If (!A_IsAdmin) {
    Run % "*RunAs " . DllCall( "GetCommandLine", "Str" ),,UseErrorLevel  ; Requires v1.0.92.01+
    ExitApp
}

EnvGet LocalAppData, LOCALAPPDATA
SplitPath A_ScriptName, , , , ScriptName
configDir = %A_AppDataCommon%\mobilmir.ru\%ScriptName%
logsDir = %A_Temp%
FileCreateDir %configDir%
FileCreateDir %logsDir%
cmdLogFName = %logsDir%\_depts_simplified.cmd.%A_Now%.log
FileDelete %configDir%\times.ahkjson
avgTFName = %configDir%\timeAvg.txt
timeMargin := 15

OnExit("CheckExit")

DllCall("kernel32.dll\SetProcessShutdownParameters", UInt, 0x4FF, UInt, 0)
OnMessage(0x11, "WM_QUERYENDSESSION")

Menu Tray, Tip, Выполняется настройка параметров безопасности файловой системы
;If (teeexe := findexe("tee.exe", "C:\SysUtils"))
;    logsuffix= 2>&1 | "%teeexe%" -a "`%TEMP`%\FSACL _depts_simplified.cmd.log"
;>"`%TEMP`%\FSACL _depts_simplified.cmd.log" 2>&1 

startTicks := A_TickCount
FileReadLine avg, %avgTFName%, 1
If (avg) {
    ticksETA := startTicks + avg + timeMargin
} Else {
    leftTime = (оставшееся время неизвестно)
}

Progress A M R%startTicks%-%ticksETA% FS8, %A_Space%`n`n`n`n`n`n`n`n, Настройка параметров доступа к ФС`n`nНе выключайте компьютер`, пока работает этот скрипт`, т.к. это может вызвать сбои.

Run %comspec% /C " "%A_ScriptDir%\_depts_simplified.cmd" >"%cmdLogFName%" 2>&1",, Hide, cmdPID
Sleep 200
cmdLogF := FileOpen(cmdLogFName, "r", "CP1")
; ToDo: seek

logLines := Object()

Loop
{
    Process Exist, %cmdPID%
    If (!ErrorLevel)
	break
    If (avg) {
	leftTime := (ticksETA - A_TickCount) // 1000
	If (leftTime < timeMargin) {
	    leftTime := "Раньше за это время скрипт уже заканчивал"
	} Else If (leftTime > 59)
	    leftTime := "Осталось " . Format("{:1.1f}", leftTime / 60) . " мин."
	Else
	    leftTime := "Осталось примерно " leftTime " с"
    }
    Progress %A_TickCount%, % leftTime "`n" GetTextLinesReverse(AddSlice(logLines, cmdLogF.ReadLine()))
    Sleep 300
}

If (avg)
    avg := (avg + (A_TickCount - startTicks)) >>1 ; 50% is previous average, 50% is current run
Else
    avg := A_TickCount - startTicks
FileAppend %avg%, %avgTFName%.tmp
FileMove %avgTFName%.tmp, %avgTFName%, 1

global finished := 1 

ExitApp %ERRORLEVEL%

GetTextLinesReverse(ByRef o) {
    i := o.MaxIndex()
    Loop
    {
	t .= o[i] . "`n"
	i--
    } Until !o.HasKey(i)
    return t
}

AddSlice(ByRef o, ByRef val, slice := 3) {
    If (v := Trim(val, " `t`n`r")) {
	o.Push(v)
	If (o.MaxIndex() - o.MinIndex() >= slice)
	    o.Delete(o.MinIndex(), o.MaxIndex()-slice)
    }
    return o
}

WM_QUERYENDSESSION(wParam, lParam)
{
    global finished
    ;ENDSESSION_LOGOFF = 0x80000000
    ;if (lParam & ENDSESSION_LOGOFF)  ; User is logging off.
    ;    EventType = Logoff
    ;else  ; System is either shutting down or restarting.
    ;    EventType = Shutdown
    ;MsgBox, 4,, %EventType% in progress.  Allow it?
    ;IfMsgBox Yes
    ;    return true  ; Tell the OS to allow the shutdown/logoff to continue.
    ;else
    ;    return false  ; Tell the OS to abort the shutdown/logoff.
    return finished
}

CheckExit(ExitReason, ExitCode) {
    If (finished || ExitReason~="^(Error|Exit)$")
	return 0
    MsgBox 0x1030, Не завершайте скрипт и не выключайте компьютер!, Уже запущена`, но ещё не закончилась настройка прав доступа.`n`nЕсли прервать выполнение сейчас`, настройки доступа к некоторым папкам могут быть нарушены. Это приводит к разным побочным эффектам: на Windows 10 может перестать работать меню Пуск; на компьютерах розницы могут перестать работать системы Билайн DOL и DOL2.`n`nДождитесь завершения скрипта и не выключайте компьютер раньше времени., 300
    return 1
}
