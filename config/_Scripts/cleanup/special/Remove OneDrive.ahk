;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

RegRead OneDriveSetup, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, OneDriveSetup
If (!ErrorLevel) {
    TrayTip %A_ScriptName%, OneDriveSetup в автозагрузке – Удаление
    RegDelete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, OneDriveSetup
    FileRemoveDir D:\Users\Пользователь\AppData\Local\Microsoft\OneDrive, 1
    Sleep 3000
}
