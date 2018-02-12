;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance ignore

EnvGet UserProfile,UserProfile
EnvGet MailUserId,MailUserId
destPath = %1%
mailDomain = mobilmir.ru

If (!MailUserId) {
    EnvGet GetSharedMailUserIdScript,GetSharedMailUserIdScript
    If Not GetSharedMailUserIdScript
	GetSharedMailUserIdScript := A_AppDataCommon "\mobilmir.ru\_get_SharedMailUserId.cmd"
    
    If (FileExist(GetSharedMailUserIdScript))
	Try MailUserId := Func("ReadSetVarFromBatchFile").Call(GetSharedMailUserIdScript, "MailUserId")
    
    If (!MailUserId && RegexMatch(A_ComputerName, "i)(.+)-[0-9k]"), m)
	MailUserId := Format("{:Ls}", m1)
}

If (MailUserId) {
    If (!destPath)
	destPath = D:\Mail\Thunderbird\profile
} Else {
    MailUserId := A_UserName
    If (!destPath)
	destPath = %UserProfile%\Mail\Thunderbird\profile
    
    Try fullName := Func("WMIGetUserFullname").Call(3)
    If (!fullName)
	fullName = (не удалось разобрать: %userFIO%)
}

Gui -Resize -MaximizeBox  
Gui Add, Text, Section, Полный адрес email: 
Gui Add, Edit, ys-2 vfullEmail, %MailUserId%@%mailDomain%
Gui Add, Text, xm Section, Папка профиля:
Gui Add, Edit, ys-2 w300 vdestPath, %destPath%
Gui Add, Text, xm Section, Имя отправителя (в формате: «Имя Фамилия»):
Gui Add, Edit, ys-2 w300 vfullName, %fullName%
Gui Add, Button, xm Section Default, OK
Gui Add, Button, ys gCancel, Отмена

Gui Show

return

ButtonOK:
    Gui Submit
    Run %A_ScriptDir%\create_new_profile.ahk %fullEmail% "%fullName%" "%destPath%"
;     "%destPath%"
    ExitApp

GuiEscape:
GuiClose:
ButtonCancel:
    ExitApp

#include *i %A_LineFile%\..\..\_Scripts\Lib\ReadSetVarFromBatchFile.ahk
#include *i %A_LineFile%\..\..\_Scripts\Lib\WMIGetUserFullname.ahk
