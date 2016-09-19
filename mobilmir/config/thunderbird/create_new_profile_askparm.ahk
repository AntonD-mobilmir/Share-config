;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance ignore

EnvGet UserProfile,UserProfile
EnvGet MailUserId,MailUserId
TargetPath = %UserProfile%\Mail\Thunderbird\profile

If (!MailUserId) {
    EnvGet GetSharedMailUserIdScript,GetSharedMailUserIdScript
    If Not GetSharedMailUserIdScript
	GetSharedMailUserIdScript=%A_AppDataCommon%\mobilmir.ru\_get_SharedMailUserId.cmd

    If (FileExist(GetSharedMailUserIdScript)) {
	MailUserId := ReadSetVarFromBatchFile(GetSharedMailUserIdScript, MailUserId)
    }
    If (!MailUserId && RegexMatch(A_ComputerName, "i).+-[0-9k]")) {
	MailUserId := Format("{:Ls}", SubStr(A_ComputerName,1,-2))
    }
    
    If (MailUserId) {
	TargetPath = D:\Mail\Thunderbird\profile
    } Else {
	MailUserId = %A_UserName%
    }
}

Gui -Resize -MaximizeBox  
Gui Add, Text, Section, Полный адрес email: 
Gui Add, Edit, ys vfullEmail, %MailUserId%@mobilmir.ru
Gui Add, Text, xm Section, Target path (directory):
Gui Add, Edit, ys w300 vTargetPath, %TargetPath%
Gui Add, Button, xm Section Default, OK
Gui Add, Button, ys, Cancel

Gui Show

return

ButtonOK:
    Gui Submit
    Run %A_ScriptDir%\create_new_profile.ahk %fullEmail% "%TargetPath%"
;     "%TargetPath%"
    ExitApp

GuiEscape:
GuiClose:
ButtonCancel:
    ExitApp

#include %A_LineFile%\..\..\_Scripts\Lib\ReadSetVarFromBatchFile.ahk
