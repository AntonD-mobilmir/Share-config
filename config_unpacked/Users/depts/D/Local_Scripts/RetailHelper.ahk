;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#NoTrayIcon
#SingleInstance force
#Persistent
Thread NoTimers

idletimeDisconnectVPN := 30 * 60 * 1000 ; 30 min in ms
idletimeRarusCheckAutoLoad := 3 * 60 * 1000 ; 3 min in ms
doublepressRarusTimeout := 20 * 60 * 1000 ; 20 min in ms
idletimeGiftomanNonOnTop := 30 * 1000 ; 30 s in ms
rebootOfferDelay := 60 * 60 * 1000 ; 1h in ms
maxIdleForMsgbox := timerPeriod := 3000 ; ms
startDay := A_DD
wintitle1s=ahk_exe 1cv7s.exe
EnvGet lProgramFiles, ProgramFiles(x86)
If (!lProgramFiles)
    lProgramFiles := A_ProgramFiles
If (FileExist(lProgramFiles "\Canon\MF Scan Utility\MFSCANUTILITY.exe"))
    checkCanonMFScan := -1 ; PID скрипта исправления ACL. Скрипт будет запущен при обнаружении MFSCANUTILITY.exe, если процесса с таким PID нет.

timeTillEndOfDay := A_YYYY . A_MM . A_DD
timeTillEndOfDay += 1, Days
timeTillEndOfDay -= A_Now, Seconds

nextRebootOffer := A_TickCount + TimeTillEndOfDay * 1000 ; ms

;ahk_class HwndWrapper[KKMGMSuite.exe;;ec6679dd-7266-4fe0-8880-fd566da471b0]
;ahk_exe KKMGMSuite.exe
GroupAdd KKMGMSuite, ahk_exe KKMGMSuite.exe

;Progress A M R0-%idletimeRarusCheckAutoLoad% T, idle
SetTimer Periodic, %timerPeriod%

; Разрешение запуска PepperFlash из папки настроек Chrome пользователя
EnvGet LocalAppData,LOCALAPPDATA
RunWait %A_WinDir%\System32\icacls.exe "%LocalAppData%\Google\Chrome\User Data\PepperFlash" /grant "%A_UserName%:(OI)(CI)M" /T /C, %A_Temp%, Min UseErrorLevel

Exit

Periodic:
    ;idle := A_TimeIdlePhysical
    idle := A_TimeIdle ; на действия самого скрипта тоже стоит реагировать
    ;Progress %idle%, %idle%
    If (idle > idletimeDisconnectVPN) {
	If (!RasDisconnected)
	    Run rasdial.exe /DISCONNECT,,Min UseErrorLevel
	;rasdial [entryname] /DISCONNECT
	RasDisconnected:=1
    } Else {
	RasDisconnected=
	If (rarusPID && A_TickCount >= nextRebootOffer && A_TimeIdlePhysical > maxIdleForMsgbox) {
	    MsgBox 0x34, Компьютер не перезагружался, Компьютер включен со вчерашнего дня.`nДля создания резервной копии 1С-Рарус требуется перезагрузка. Перезагрузить сейчас?`n`n(если ответите нет – перезагрузите сами при первой возможности), 60
	    IfMsgBox No
	    {
		nextRebootOffer := A_TickCount + rebootOfferDelay ; ms
	    } Else {
		WinClose %wintitle1s%
		WinWaitClose,,, 30 ; seconds to wait for close
		Shutdown 2
	    }
	} Else {
	    rarusPID := getFirstPid("1cv7s.exe", "1cv7.exe")
	}
	
	If (checkCanonMFScan) {
	    Process Exist, MFSCANUTILITY.exe
	    If (ErrorLevel) { ; если утилита запущена
		Process Exist, %checkCanonMFScan%
		If (!ErrorLevel) ; а скрипт – не запущен
		    Run "%A_AhkPath%" "%A_ScriptDir%\Reset ACL after Canon MF Scan Utility.ahk",,,checkCanonMFScan
	    }
	}
    }
    
;Гифтоман
    If (idle > idletimeGiftomanNonOnTop && WinExist("ahk_group KKMGMSuite")) {
	If (transp > 50)
	    transp-=10
	IfWinActive
	{
	    WinSet Transparent, %transp%
	    WinSet AlwaysOnTop, Off
	} Else {
	    transp:=255
	    WinSet Transparent, Off
	}
    }
;Рарус
    rarusMinMax := 2
    If (idle > idletimeRarusCheckAutoLoad && A_TickCount > rarusLoadNextCheck && WinExist(wintitle1s)) {
	ControlGetText txtBtn, Button20
	If (ErrorLevel || txtBtn != "ОБМЕН УТ") {
	    WinGet rarusMinMax, MinMax
	    If (rarusMinMax == -1)
		WinRestore
	    ControlSend ahk_parent, {F12}
	    ;Progress,, Фронт кассира развернут
	    Sleep 2000
	    ControlGetText txtBtn, Button20
	    If (ErrorLevel || txtBtn != "ОБМЕН УТ") ; че-то не сработало
		Exit
	}
	ControlGetText txtStatic, Static2
	If (ErrorLevel || txtStatic != "ОБМЕН УТ")
	    Exit
	; кроме Static2, можно проверять видимость Button21, но Button21 -- без текста
	ControlGet s2vis, Visible,, Static2
	If (!ErrorLevel && s2vis) { ; кнопка – красная
	    If (rarusMinMax == 2) {
		WinGet rarusMinMax, MinMax
		If (rarusMinMax == -1)
		    WinRestore
	    }
	    ControlClick Button20 ; ОБМЕН УТ
	    rarusLoadNextCheck := A_TickCount + doublepressRarusTimeout
	}
	If (rarusMinMax = -1)
	    WinMinimize
    }
return

getFirstPid(exeNames*) {
    For i,Name in exeNames {
	Process Exist, %Name%
	If (ErrorLevel)
	    return ErrorLevel
    }
    return
}
