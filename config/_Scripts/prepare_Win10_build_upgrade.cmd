@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS

CALL "%~dp0cleanup\uninstall_soft.cmd"
START "BleachBit" /WAIT /MIN %comspec% /C "%~dp0cleanup\BleachBit-auto.cmd" /ProfileOnSystemDrive
START "cleanup\cleanmgr-full.cmd" %comspec% /C "%~dp0cleanup\cleanmgr-full.cmd"
RD /S /Q "%APPDATA%\..\LocalLow\Sun"
REM Удаление БД Offline-файлов https://support.microsoft.com/en-us/help/942974/
%SystemRoot%\System32\REG.exe ADD "HKLM\System\CurrentControlSet\Services\CSC\Parameters" /v FormatDatabase /t REG_DWORD /d 1 /f

"%~dp0FindAutoHotkeyExe.cmd" "%~dp0MoveUserProfile\Restore Profiles Directory from backup.ahk"
REG IMPORT "%~dp0MoveUserProfile\HKLM ProfilesDirectory SystemDrive_Users.reg"
REG IMPORT "%~dp0MoveUserProfile\HKLM User Shell Folders original.reg"
)
