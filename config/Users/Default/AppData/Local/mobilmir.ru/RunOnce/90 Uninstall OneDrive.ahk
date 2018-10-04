#NoEnv
#SingleInstance force
FileEncoding UTF-8

If A_OSVersion in WIN_VISTA,WIN_7,WIN_8,WIN_8.1
    ExitApp

Loop
{
    Process Exist, OneDriveSetup.exe
    If (!ErrorLevel)
        break
    If (A_Index == 1)
        Progress R%A_TickCount%-%timelimit% M A, Ожидание завершения установки OneDrive…, Удаление OneDrive, OneDrive ещё устанавливается
    Process WaitClose, OneDriveSetup.exe ; there may be many
}
Progress Off

EnvGet LocalAppData, LocalAppData
RegRead OneDriveSetup, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run, OneDriveSetup
If (!ErrorLevel) {
    RegDelete HKEY_CURRENT_USER\%RunKey%, OneDriveSetup
    TrayTip OneDriveSetup удалён из автозагрузки
    FileRemoveDir %LocalAppData%\Microsoft\OneDrive, 1
}

;ShortcutPath = %A_Programs%\OneDrive.lnk

timelimit := A_TickCount + 3*60000 ; 3 minutes

Progress R%A_TickCount%-%timelimit% M A, Ожидание появления записи OneDrive в реестре…`n, Удаление OneDrive, Удаление OneDrive
While !(uncmd := GetOneDriveUninstallString()) {
    If (A_TickCount > timelimit)
        ExitApp 0
    Sleep 1000
    Progress %A_TickCount%
}

Try DefaultConfigDir:=getDefaultConfigDir()
If (!DefaultConfigDir)
    DefaultConfigDir := "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config"

; нельзя так делать, поскольку записи – в реестре пользователя
;If (!A_IsAdmin) {
;    Run % "*RunAs " DllCall( "GetCommandLine", "Str" ),,UseErrorLevel
;    If (!ErrorLevel)
;        Sleep 3000
;}

Loop
{
    Progress,, Найдено: %uncmd%`nЗапуск "cleanup\uninstall\050 OneDrive.ahk"
    RunWait "%A_AhkPath%" "%DefaultConfigDir%\_Scripts\cleanup\uninstall\050 OneDrive.ahk",, UseErrorLevel
    savedErr := ErrorLevel
    If (uncmd := GetOneDriveUninstallString()) {
        Progress,, OneDrive не удалён`, код ошибки: %ERRORLEVEL%`nПовторная попытка через 10 с
        Sleep 10000
    } Else
        break
}
FileRemoveDir %LocalAppData%\Microsoft\OneDrive, 1
ExitApp savedErr

GuiEscape:
GuiClose:
    ExitApp

GetOneDriveUninstallString() {
    static UninstRegKey := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe"
    RegRead v, %UninstRegKey%, UninstallString
    return v
}

#include <getDefaultConfig>
