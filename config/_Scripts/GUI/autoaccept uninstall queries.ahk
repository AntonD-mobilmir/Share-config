;Script to automatically confirm GUI uninstall queries
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

If (!A_IsAdmin) {
    FileAppend %A_Now% Запрос перезапуска с правами администратора`n, *, CP0
    Run % "*RunAs " DllCall( "GetCommandLine", "Str" ),,UseErrorLevel  ; Requires v1.0.92.01+
    ExitApp
}

cases := []
;Title	WinText	Buttons to press
Loop Read, %casesFullPath%
{
    winTitle:=winText:=xtra:=""
    clickList:=[]
    Loop Parse, A_LoopReadLine, CSV
    {
	If (A_Index = 1) {
	    winTitle := A_LoopField
	    continue
	} Else If (A_Index = 2) {
	    winText := A_LoopField
	    continue
	} Else {
	    If (Trim(A_LoopField))
		clickList[A_Index - 2] := A_LoopField
	}
    }
    cases[A_Index] := {winTitle: winTitle, winText: winText, clickList: clickList}
}
FileAppend %A_Now% Список окон прочитан`n, *, CP0

Loop {
    WaitCPUIdle()
    FileGetTime scriptCurDate, %A_ScriptFullPath%
    FileGetTime casesCurDate, %casesFullPath%
    If ((scriptCurDate && scriptCurDate != scriptInitDate) || (casesCurDate && casesInitDate != casesCurDate)) {
	FileAppend %A_Now% Обнаружено изменение скрипта или списка окон`, перезапуск.`n, *, CP0
	ToolTip Перезапуск скрипта
	Sleep 500
	Reload
	Pause
    }
    
    FileAppend %A_Now% Проверка окон`n, *, CP0
    For i, case in cases {
	While (A_TimeIdlePhysical < 3000) {
	    sleepTime := 2 + (A_Index > 10 ? 10 : A_Index)
	    FileAppend %A_Now% %A_Index% раз обнаружены действия пользователя`, ожидание простоя %sleepTime% с`n, *, CP0
	    ToolTip Ожидание простоя [%sleepTime% c]
	    Sleep 300+sleepTime*1000-A_TimeIdlePhysical
	}
	;ToolTip % "Проверка:`n" case.winTitle "`n" case.winText
	If (WinExist(case.winTitle, case.winText)) {
	    FileAppend % A_Now " Найдено окно " ObjectToText(case) "`n", *, CP0
	    TrayTip
	    Menu Tray, NoIcon
	    Menu Tray, Icon
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
    FileAppend % A_Now Перезапуск по нажатию %A_ThisHotkey%`n, *, CP0
    TrayTip,, Перезапуск по нажатию %A_ThisHotkey%
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

ObjectToText(obj) {
    out := ""
    For i,v in obj
	out .= i ": " ( IsObject(v) ? "(" ObjectToText(v) ")" : (InStr(v, ",") ? """" v """" : v) ) ", "
    return SubStr(out, 1, -2)
}

WaitCPUIdle() {
    SetFormat FloatFast, 3.2
    
    cycle:=0
    cyclesLimit:=3
    OneSecond:=1000
    idleLimit:=0.75
    idleLimitPct:=Round(idleLimit * 100,2)
    
    GetIdleTime()
    Loop {
	Sleep %OneSecond%
	idle := GetIdleTime()
	FileAppend %A_Now% Доля холостых циклов процессора: %idle%`n, *, CP0
	If (idle > idleLimit) {
	    If (A_Index == 1) ; если при первой проверке ниже предела, выход
		break
	    cycle++
	} Else
	    cycle := 0
	If (A_Index == 1) {
	    Progress Off
	    Progress A R0-%cyclesLimit%, `n, % "Ожидание " . idleLimitPct . "% простоя процессора в течение " . cyclesLimit . " с"
	    FileAppend %A_Now% Ожидание %idleLimit% простоя процессора в течение %cyclesLimit% с`n, *, CP0
	}
	Progress %cycle%, % "Текущий процент простоя: " . idle*100
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
