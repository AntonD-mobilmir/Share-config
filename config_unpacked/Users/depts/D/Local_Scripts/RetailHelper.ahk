;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#NoTrayIcon
#SingleInstance force
#Persistent
Thread NoTimers

idletimeDisconnectVPN := 30 * 60 * 1000 ; 30 min
idletimeRarusRestore := 10 * 60 * 1000 ; 10 min
idletimeRarusCheckAutoLoad := 3 * 60 * 1000 ; 3 min
idletimeGiftomanNonOnTop := 30 * 1000 ; 30 sec

;ahk_class HwndWrapper[KKMGMSuite.exe;;ec6679dd-7266-4fe0-8880-fd566da471b0]
;ahk_exe KKMGMSuite.exe
GroupAdd KKMGMSuite, ahk_exe KKMGMSuite.exe

SetTimer Periodic, 3000

Exit

Periodic:
    idle := A_TimeIdle ; на действия самого скрипта тоже стоит реагировать
    ;idle := A_TimeIdlePhysical
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
    If (idle > idletimeRarusCheckAutoLoad && WinExist("ahk_exe 1cv7s.exe")) {
	;WinGet rarusMinMax, MinMax
	;If (rarusMinMax = -1)
	;    WinRestore
	ControlGetText txtBtn, Button20
	If (ErrorLevel || txtBtn != "ОБМЕН УТ") {
	    ControlSend F12
	    Sleep 2000
	}
	ControlClick Button20 ; ОБМЕН УТ
    }
return
