@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF DEFINED PROCESSOR_ARCHITEW6432 "%SystemRoot%\SysNative\cmd.exe" /C %0 %* & EXIT /B
SETLOCAL ENABLEEXTENSIONS
SET "configDir=%~dp0"
CALL "%~dp0_Scripts\Lib\.utils.cmd" CheckSetSystemVars
CALL "%~dp0_Scripts\FindAutoHotkeyExe.cmd"
CALL "%~dp0_Scripts\FindSoftwareSource.cmd"

SET "Пользователь_flags=f"
CALL "%~dp0_Scripts\AddUsers\Add_Admins.cmd"
CALL "%~dp0_Scripts\AddUsers\AddUser_Install.cmd"
START "Inventory\collector-script\SaveArchiveReport.cmd" /B %comspec% /C "%~dp0..\Inventory\collector-script\SaveArchiveReport.cmd"
START "..\Program Files\collectProductKeys.exe" /B "%~dp0..\Program Files\collectProductKeys.exe"
)

(
CALL "%SoftSourceDir%\Archivers Packers\7Zip\install.cmd"
CALL "%SoftSourceDir%\Keyboard Tools\AutoHotkey\install.cmd"
CALL "%SoftSourceDir%\PreInstalled\prepare.cmd"

SET "DefaultsSource=%~dp0Apps_roaming.7z"
CALL "%SoftSourceDir%\Network\Remote Control\Remote Desktop\TeamViewer 5\install.cmd" TeamViewer_Host.msi TeamViewer_ServiceNote.reg
rem only runnable on an admin's PC: %AutohotkeyExe% "%configDir%_Scripts\GUI\Gen TeamViewer Passwd.ahk", and not required since 2016-08-31
SET "DefaultsSource="

%AutohotkeyExe% "%SoftSourceDir%\AntiViruses AntiTrojans\Microsoft Security Essentials\install.ahk"

%AutohotkeyExe% "%~dp0_Scripts\GUI\Run_UserBenchMark.ahk"
)
