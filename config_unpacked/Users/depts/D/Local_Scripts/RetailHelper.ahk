;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#NoTrayIcon
#SingleInstance force
#Persistent
Thread NoTimers

idletimeDisconnectVPN := 30 * 60 * 1000 ; 30 min
idletimeRarusCheckAutoLoad := 3 * 60 * 1000 ; 3 min
doublepressRarusTimeout := 20 * 60 * 1000 ; 20 min
idletimeGiftomanNonOnTop := 30 * 1000 ; 30 sec

;ahk_class HwndWrapper[KKMGMSuite.exe;;ec6679dd-7266-4fe0-8880-fd566da471b0]
;ahk_exe KKMGMSuite.exe
GroupAdd KKMGMSuite, ahk_exe KKMGMSuite.exe

;Progress A M R0-%idletimeRarusCheckAutoLoad% T, idle
SetTimer Periodic, 3000

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
    If (idle > idletimeRarusCheckAutoLoad && A_TickCount > rarusLoadNextCheck && WinExist("ahk_exe 1cv7s.exe")) {
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
