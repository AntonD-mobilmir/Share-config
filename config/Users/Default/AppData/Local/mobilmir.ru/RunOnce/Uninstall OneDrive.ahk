#NoEnv
#SingleInstance force
FileEncoding UTF-8

timelimit := A_TickCount + 3*60000 ; 3 minutes

Progress R%A_TickCount%-%timelimit% M A, Ожидание появления записи OneDrive в реестре…`n, Удаление OneDrive, Удаление OneDrive
Loop
{
    Progress %A_TickCount%
    Sleep 1000
    RegRead UninstallString, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe, UninstallString
} Until UninstallString || A_TickCount > timelimit

If (!UninstallString)
    ExitApp 1

Try DefaultConfigDir:=getDefaultConfigDir()
If (!DefaultConfigDir)
    DefaultConfigDir:="\\Srv0.office0.mobilmir\profiles$\Share\config"

Progress,, Найдено: %UninstallString%`nЗапуск "cleanup\uninstall\050 OneDrive.ahk"
Run "%A_AhkPath%" "%DefaultConfigDir%\_Scripts\cleanup\uninstall\050 OneDrive.ahk",, UseErrorLevel
ExitApp ErrorLevel

GuiEscape:
GuiClose:
    ExitApp

#include <getDefaultConfig>
