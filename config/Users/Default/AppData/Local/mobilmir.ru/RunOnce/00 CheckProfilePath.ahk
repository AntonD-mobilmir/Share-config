;Предупреждение по первом входе, если профиль на C: https://redbooth.com/a/#!/projects/59756/tasks/34494483
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

If (A_UserName = "Install")
    ExitApp

specBaseDir := "D:\Users"

EnvGet UserProfile,UserProfile
SplitPath UserProfile,,profileBaseDir,,,profileDrive

If (profileBaseDir != specBaseDir) {
    EnvGet SystemDrive,SystemDrive
    
    
    If (profileDrive = SystemDrive && InStr(FileExist("D:\Users"), "D"))
	errText := "Профиль пользователя находится на системном диске, но обычно после настройки по спецификации он должен создаваться в """ specBaseDir """."
    Else
	errText := "Папка, в которой создан профиль, не соответствует спецификации."
    
    RegRead ProfilesDirectory, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory
    MsgBox 0x30, Проверка папки профилей при первом запуске, % errText "`n`nЕсли так не должно быть, стоит исправить и удалить этот профиль, прежде чем продолжать.`n`nПрофиль пользователя: """ UserProfile """`nПапка для новых профилей в реестре: """ ProfilesDirectory """`nСистемный диск: " SystemDrive
}
