;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

scriptName=Отложенный автозапуск

If %0%
{
    TrayTip %scriptName%, Ожидание простоя процессора`, после чего будут запущены программы.
    WaitCPUIdle()
    TrayTip
    
    StringLeft flag, 1, 1
    If (flag=="@") {
	StringMid listFileName, 1, 2
	Loop Read, %listFileName%
	{
	    StringSplit arrayRunStr, A_LoopReadLine, `t
	    RunAndWaitWindow(arrayRunStr1,arrayRunStr2,arrayRunStr3)
	}
    }
    
    Loop %0%
    {
	RunAndWaitWindow(%A_Index%)
    }
} Else {
    MsgBox В качестве параметров необходимо указать полные пути к программам, либо "@путь к файлу со списком программ.txt" которые должны быть автоматически запущены.`nКаждая строка списка программ:`nпуть к программе<tab>параметры<tab>отображаемое название<enter>
}

ExitApp

RunAndWaitWindow(pathRunProgram, param="", nameRunProgram="") {
    SplitPath pathRunProgram, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
    If (nameRunProgram=="") {
	nameRunProgram=%OutNameNoExt%
    }
    TrayTip %scriptName%, Запуск %nameRunProgram%…
    Run "%pathRunProgram%" %param%,%OutDir%,UseErrorLevel,aPID
    If (ErrorLevel=="ERROR")
    {
	TrayTip
	TrayTip %scriptName% – ошибка запуска %A_LoopFileName%, %A_LoopFileFullPath% не может быть запущен`, исправьте ярлык в автогразуке или обратитесь к технической поддержке.
	Sleep 3000
    } Else {
	SetTimer ShowWaitingMsg, -3000
	WinWait ahk_pid %aPID%,,15
	SetTimer ShowWaitingMsg, Off
    }
    TrayTip
}

WaitCPUIdle() {
    FileAppend Start waiting for idle CPU`n, *
    GetIdleTime()
    SetFormat FloatFast, 3.2
    times := 0
    Loop
    {
	Sleep 1000
	idle := GetIdleTime()
	If (idle < 0.9) {
	    times := 0
	} Else {
	    If (times > 5)
		break
	    times++
	}
	Menu Tray, Tip, % "Ожидание 90% простоя процессора. Текущий простой: " . idle*100
    }
    Menu Tray, Tip
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

ShowWaitingMsg:
    TrayTip %scriptName%, Ожидание появления окна запущенной программы…
return
