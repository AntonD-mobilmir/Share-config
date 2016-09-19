;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
#SingleInstance force

SendMode InputThenPlay
SetBatchLines -1

;http://support.microsoft.com/kb/315231
AutoLogonCount=%2%

If %1%
    Username = %1%
Else
{
    RegRead Username, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, DefaultUserName
    If Not %AutoLogonCount%
	RegRead AutoLogonCount, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, AutoLogonCount
    Gui Add, Text, xm, Username:
    Gui Add, Edit, ym X100 W100 vUsername, %Username%
    Gui Add, Text, xs Section, AutoLogonCount:
    Gui Add, Edit, ys X100 W100 vAutoLogonCount, %AutoLogonCount%
    Gui Add, Button, xm wp Default, OK
    Gui Show
    Exit
}

ButtonOK:
Gui Submit
RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, AutoAdminLogon, 1
RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, DefaultUserName, %Username%

If %AutoLogonCount%
    RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, AutoLogonCount, %AutoLogonCount%
Else
    RegDelete HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon, AutoLogonCount

GuiClose:
GuiEscape:
ExitApp
