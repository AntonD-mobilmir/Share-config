#NoEnv
#SingleInstance force
FileEncoding UTF-8

If A_OSVersion in WIN_VISTA,WIN_7,WIN_8,WIN_8.1
    ExitApp

;ShortcutPath = %A_Programs%\OneDrive.lnk

timelimit := A_TickCount + 3*60000 ; 3 minutes

Progress R%A_TickCount%-%timelimit% M A, Ожидание появления записи OneDrive в реестре…`n, Удаление OneDrive, Удаление OneDrive
While !(uncmd := GetOneDriveUninstallString()) {
    If (A_TickCount > timelimit)
        ExitApp 1
    Sleep 1000
    Progress %A_TickCount%
}

Try DefaultConfigDir:=getDefaultConfigDir()
If (!DefaultConfigDir)
    DefaultConfigDir := "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config"

Loop
{
    Progress,, Найдено: %uncmd%`nЗапуск "cleanup\uninstall\050 OneDrive.ahk"
    RunWait "%A_AhkPath%" "%DefaultConfigDir%\_Scripts\cleanup\uninstall\050 OneDrive.ahk",, UseErrorLevel
    If (uncmd := GetOneDriveUninstallString()) {
        Progress,, OneDrive не удалён`, код ошибки: %ERRORLEVEL%`nПовторная попытка через 10 с
        Sleep 10000
    } Else
        break
}
ExitApp ErrorLevel

GuiEscape:
GuiClose:
    ExitApp

GetOneDriveUninstallString() {
    UninstRegKey = HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe
    RegRead v, %UninstRegKey%, UninstallString
    return v
}

#include <getDefaultConfig>
