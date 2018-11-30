@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    %SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )

    IF DEFINED PROCESSOR_ARCHITEW6432 "%SystemRoot%\SysNative\cmd.exe" /C "%0 %*" & EXIT /B
    SETLOCAL ENABLEEXTENSIONS
    SET "configDir=%~dp0"
    CALL "%~dp0_Scripts\Lib\.utils.cmd" CheckSetSystemVars
    CALL "%~dp0_Scripts\FindAutoHotkeyExe.cmd"
    CALL "%~dp0_Scripts\FindSoftwareSource.cmd"

    SET "Пользователь_flags=rpf"
    START "Добавление стандартных администраторов" %comspec% /C "%~dp0_Scripts\AddUsers\Add_Admins.cmd"
    CALL "%~dp0_Scripts\AddUsers\AddUser_Install.cmd"
    START "Inventory\collector-script\SaveArchiveReport.cmd" /B %comspec% /C "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Inventory\collector-script\SaveArchiveReport.cmd"
    START "run_collectProductKeys" /MIN %comspec% /C "%~dp0_Scripts\run_collectProductKeys.cmd"

    IF EXIST "%SystemDrive%\Windows\SwapSpace" CALL :TestDestMovePagefile
)
(
    CALL "%SoftSourceDir%\Archivers Packers\7Zip\install.cmd"
    CALL "%SoftSourceDir%\Keyboard Tools\AutoHotkey\install.cmd"
    CALL "%SoftSourceDir%\PreInstalled\prepare.cmd"
    IF EXIST "D:\Users\Public" %AutohotkeyExe% "%~dp0_Scripts\MoveUserProfile\SetProfilesDirectory_D_Users.ahk"
    
    SET "DefaultsSource=%~dp0Apps_roaming.7z"
    CALL "%SoftSourceDir%\Network\Remote Control\Remote Desktop\TeamViewer 5\install.cmd" TeamViewer_Host.msi TeamViewer_ServiceNote.reg
    SET "DefaultsSource="
    rem only runnable on an admin's PC: %AutohotkeyExe% "%configDir%_Scripts\GUI\Gen TeamViewer Passwd.ahk", and not required since 2016-08-31
    
    %AutohotkeyExe% "%SoftSourceDir%\AntiViruses AntiTrojans\Microsoft Security Essentials\install.ahk"
    
    %AutohotkeyExe% "%~dp0_Scripts\GUI\Run_UserBenchMark.ahk"
EXIT /B
)
:TestDestMovePagefile
(
    IF NOT EXIST "%SystemDrive%\Windows\SwapSpace\test.tmp" ECHO %DATE% %TIME% "%~f0" testing access>"%SystemDrive%\Windows\SwapSpace\test.tmp" || EXIT /B
    IF NOT EXIST "%SystemDrive%\Windows\SwapSpace\test.tmp" EXIT /B 1
    DEL "%SystemDrive%\Windows\SwapSpace\test.tmp" || EXIT /B
    IF EXIST "%SystemDrive%\Windows\SwapSpace\test.tmp" EXIT /B 1
    CALL "%~dp0_Scripts\pagefile_on_Windows_SwapSpace.cmd"
)
