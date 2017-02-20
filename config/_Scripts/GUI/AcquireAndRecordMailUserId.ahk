;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance force

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    If (!A_IsAdmin) {
	Run % "*RunAs " . DllCall( "GetCommandLine", "Str" ),,UseErrorLevel  ; Requires v1.0.92.01+
	ExitApp
    }
    
    MailUserId := GetMailUserId(GetSharedMailUserIdScript)
    If (!MailUserId) {
	SplitPath GetSharedMailUserIdScript,,GetSharedMailUserIdScriptDir

	If (RegexMatch(A_ComputerName, "i).+-[0-9k]")) {
	    MailUserId := Format("{:Ls}", SubStr(A_ComputerName,1,-2))
	}
    }

    InputBox MailUserId, Имя пользователя e-mail, Введите имя почтового ящика (адрес e-mail пользователя до @),,,,,,,, %MailUserId%
    If (MailUserId) {
	FileCreateDir %GetSharedMailUserIdScriptDir%
	FileDelete %GetSharedMailUserIdScript%
	FileAppend @(REM coding:CP866`nSET MailUserId=%MailUserId%`n)`n,%GetSharedMailUserIdScript%,CP866
    }
    Exit
}

#include %A_LineFile%\..\..\Lib\GetMailUserId.ahk
