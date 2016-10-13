﻿;Script to automatically confirm GUI uninstall queries
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
#SingleInstance Force
#InstallKeybdHook
#InstallMouseHook
SetTitleMatchMode RegEx
FileEncoding UTF-8

SplitPath A_ScriptFullPath,,,, casesFullPath
casesFullPath = %A_ScriptDir%\%casesFullPath%.csv
FileGetTime scriptInitDate, %A_ScriptFullPath%
FileGetTime casesInitDate, %casesFullPath%

Global Log
Log=%A_Desktop%\%A_ScriptName% ClickLog.log

if not A_IsAdmin
{
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    if ErrorLevel = ERROR
	MsgBox Без прав администратора ничего не выйдет.
    ExitApp
}

cases := Object()
;Title	WinText	Buttons to press
Loop Read, %casesFullPath%
{
    Loop Parse, A_LoopReadLine, CSV
    {
	If (A_Index = 1) {
	    winTitle := A_LoopField
	    continue
	} Else If (A_Index = 2) {
	    winText := A_LoopField
	    continue
	} Else If (A_Index = 3) {
	    clickList:=Object()
	}
	If (Trim(A_LoopField))
	    clickList.Push(A_LoopField)
    }
    cases[A_Index] := {winTitle: winTitle, winText: winText, clickList: clickList}
    clickList=
}

Loop {
    WaitCPUIdle()
    FileGetTime scriptCurDate, %A_ScriptFullPath%
    FileGetTime casesCurDate, %casesFullPath%
    If ((scriptCurDate && scriptCurDate != scriptInitDate) || (casesCurDate && casesInitDate != casesCurDate)) {
	ToolTip Перезапуск скрипта
	Sleep 500
	Reload
	Pause
    }
    
    For i, case in cases {
	While (A_TimeIdlePhysical < 3000) {
	    sleepTime := 2+A_Index
	    ToolTip Ожидание простоя [%sleepTime% c]
	    Sleep 300+sleepTime*1000-A_TimeIdlePhysical
	}
	ToolTip % "Проверка:`n" case.winTitle "`n" case.winText
	If (WinExist(case.winTitle, case.winText)) {
	    TrayTip % "Найдено окно " case.winTitle, % "`n" case.winText
	    cclick(case.clickList*)
	    continue
	}
    }
    ToolTip
    
    Sleep 1000
}

ExitApp

#Esc::	ExitApp
#!SC52:: ;R = SC52 #!R
    TrayTip Reloading, Reloading due to Win+Alt+R
    Sleep 1000
    Reload
    return
Pause::	Pause

cclick(labels*) {
    static prevLabel, lastClick
    
    clickDelay := A_TickCount - lastClick

    For i,label in labels {
	WinGetTitle Title
	FileAppend %A_Now% in "%Title%" clicked %label%`n,%Log%
	ControlClick %label%
	tooltipText .= A_Space . label
    }
    ToolTip Clicked%tooltipText%
    If (clickDelay < 1000) {
	If (prevLabels=tooltipText)
	    Sleep 10000
	Else
	    Sleep 1000 - clickDelay
    }
    prevLabels:=tooltipText
    lastClick:=A_TickCount
    return
}

WaitCPUIdle() {
    SetFormat FloatFast, 3.2
    
    cycle:=0
    cyclesLimit:=10
    measurementTime:=1000
    measurementTime_s:=measurementTime // 1000
    idleLimit:=0.75
    idleLimitPct:=Round(idleLimit * 100,2)
    
    FileAppend %A_Now% Проверка нагрузки на процессор / ожидание освобождения ресурсов`n, *
    GetIdleTime()
    Progress Off
    Progress A R0-%cyclesLimit%, `n, % "Ожидание " . idleLimitPct . "% простоя процессора в течение " . cyclesLimit . " секунд"
    Loop {
	Loop
	{
	    Sleep %measurementTime%
	    idle := GetIdleTime()
	    If (idle > idleLimit)
		break
	    Else
		cycle := 0
	    Progress %cycle%, % "Текущий процент простоя: " . idle*100
	}
	cycle++
    } Until cycle > cyclesLimit
    Progress Off
}

;http://www.autohotkey.com/board/topic/11910-cpu-usage/
GetIdleTime()    ;idle time fraction
{
    Static oldIdleTime, oldKrnlTime, oldUserTime
    Static newIdleTime, newKrnlTime, newUserTime

    oldIdleTime := newIdleTime
    oldKrnlTime := newKrnlTime
    oldUserTime := newUserTime

    DllCall("GetSystemTimes", "int64P", newIdleTime, "int64P", newKrnlTime, "int64P", newUserTime)
    Return (newIdleTime-oldIdleTime)/(newKrnlTime-oldKrnlTime + newUserTime-oldUserTime)
}
