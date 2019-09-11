;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance ignore

EnvGet UserProfile,UserProfile
EnvGet mailUserId,mailUserId
destPath := A_Args[1]
mailUserID := A_Args[2]
If (atPos := InStr(mailUserID, "@"))
    mailDomain := SubStr(mailUserID, atPos+1), mailUserID := SubStr(mailUserID, 1, atPos-1)

If (!mailUserId) {
    EnvGet GetSharedmailUserIdScript,GetSharedmailUserIdScript
    If (!GetSharedmailUserIdScript)
	GetSharedmailUserIdScript := A_AppDataCommon "\mobilmir.ru\_get_SharedmailUserId.cmd"
    
    If (FileExist(GetSharedmailUserIdScript))
	Try mailUserId := Func("ReadSetVarFromBatchFile").Call(GetSharedmailUserIdScript, "mailUserId")
    
    If (!mailUserId && RegexMatch(A_ComputerName, "i)(.+)-[0-9k]"), m)
	mailUserId := Format("{:Ls}", m1)
}

If (mailUserId) { ; Компьютер в рознице либо другой общий с общим профилем почты
    If (!destPath) {
        destPath = D:\Mail\Thunderbird\profile
        testfname = %destPath%\test.%A_Now%.%A_TickCount%.tmp
        FileCreateDir %destPath%
        FileDelete %testfname%
        FileAppend,,%testfname%
        If (!FileExist(testfname))
            destPath := ""
        FileDelete %testfname%
    }
    
    fullName := FindDeptById(mailUserId, line) " (отдел" (A_ComputerName ~= "i)-K$" ? ", касса" : "") ")"
    If (!mailDomain)
        mailDomain := line["mailDomain"]
} Else {
    mailUserId := A_UserName
    Try fullName := Func("WMIGetUserFullname").Call(2)
    If (!fullName)
        fullName = (не удалось разобрать: %userFIO%)
}
    
If (!destPath)
    destPath = %UserProfile%\Mail\Thunderbird\profile
If (!mailDomain)
    mailDomain = mobilmir.ru

Gui -Resize -MaximizeBox  
Gui Add, Text, Section, Полный адрес email: 
Gui Add, Edit, ys-2 vfullEmail, %mailUserId%@%mailDomain%
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
    ExitApp

GuiEscape:
GuiClose:
ButtonCancel:
    ExitApp

#include *i %A_LineFile%\..\..\_Scripts\Lib\ReadSetVarFromBatchFile.ahk
#include *i %A_LineFile%\..\..\_Scripts\Lib\WMIGetUserFullname.ahk
#include *i %A_LineFile%\..\..\_Scripts\Lib\FindDeptById.ahk
