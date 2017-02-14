;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#NoTrayIcon
#SingleInstance force
#Persistent

;ahk_class HwndWrapper[KKMGMSuite.exe;;ec6679dd-7266-4fe0-8880-fd566da471b0]
;ahk_exe KKMGMSuite.exe
GroupAdd KKMGMSuite, ahk_exe KKMGMSuite.exe

SetTimer Periodic, 3000

Loop
{
    transp:=255
    WinWaitActive ahk_group KKMGMSuite
    WinSet Transparent, Off
}

Periodic:
;Отключить VPN, если компьютер не трогают пол-часа
;rasdial [entryname] /DISCONNECT
    If (A_TimeIdlePhysical > 1800000) {
	If (!RasDisconnected)
	    Run rasdial.exe /DISCONNECT,,Min UseErrorLevel
	RasDisconnected:=1
    } Else {
	RasDisconnected=
    }
    
;Гифтоман
    If (transp > 50)
	transp-=10
    IfWinActive ahk_group KKMGMSuite
    WinSet AlwaysOnTop, Off
    WinSet Transparent, %transp%
return
