@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
%SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )

IF DEFINED PROCESSOR_ARCHITEW6432 "%SystemRoot%\SysNative\cmd.exe" /C "%0 %*" & EXIT /B
SETLOCAL ENABLEEXTENSIONS
SET "configDir=%~dp0"
CALL "%~dp0_Scripts\Lib\.utils.cmd" CheckSetSystemVars
CALL "%~dp0_Scripts\FindAutoHotkeyExe.cmd"
IF NOT DEFINED exe7z CALL "%~dp0_Scripts\find7zexe.cmd" || PAUSE
IF NOT DEFINED xlnexe CALL "%~dp0_Scripts\find_exe.cmd" xlnexe xln.exe || PAUSE
)
(
%AutohotkeyExe% "%~dp0_Scripts\EjectCDDrivesIfNotEmpty.ahk"
rem @ECHO Самое время настроить прокси, если это ещё не сделано
rem rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,,4
)
:restart
IF NOT EXIST D:\ ECHO Driveletter D: [Data] not accessible & PAUSE & GOTO :restart

rem CALL "%~dp0_Scripts\FindSoftwareSource.cmd"
rem Dirty way to get paths in any situation
rem SET PATH=%PATH%;%ProgramData%\mobilmir.ru\Common_Scripts;%SystemDrive%\SysUtils;%SystemDrive%\SysUtils\gnupg;%SystemDrive%\SysUtils\lbrisar;%SystemDrive%\SysUtils\libs;%SystemDrive%\SysUtils\libs\OpenSSL;%SystemDrive%\SysUtils\libs\OpenSSL\bin;%SystemDrive%\SysUtils\ResKit;%SystemDrive%\SysUtils\SysInternals;%SystemDrive%\SysUtils\UnxUtils;%SystemDrive%\SysUtils\UnxUtils\Uri

REM parsing command line arguments
SET arg=%~1
SET argflag=%arg:~,1%
SET argvalue=%arg:~1%
IF /I "%argflag%"==":" (
    SHIFT /1
    SET arg=
    GOTO :%argvalue%
)

TITLE Initial config
START "Добавление стандартных администраторов" %comspec% /C "%~dp0_Scripts\AddUsers\Add_Admins.cmd"

REM Writing DefaultsSource
IF NOT EXIST "%ProgramData%\mobilmir.ru" MKDIR "%ProgramData%\mobilmir.ru"
SET "DefaultsSourceScript=%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
SET "DefaultsSource=%~dp0Apps_office.7z"
(ECHO SET DefaultsSource=%DefaultsSource%)>"%DefaultsSourceScript%"

REM Executing _business_config.cmd
CALL "%~dp0_Scripts\_business_config.cmd"
rem WMIC computersystem where name="%COMPUTERNAME%" call joindomainorworkgroup name="OFFICE0"
rem REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Domain" /d "office0.mobilmir" /f

:All
REM Common procedure
TITLE Running _all.cmd
CALL "%~dp0_all.cmd" %arg%

:AfterAll
rem Without running ahk as an app (just starting .ahk), START /I misbehaves, ignoring the switch
CALL "%~dp0_Scripts\FindAutoHotkeyExe.cmd"
CALL "%~dp0_Scripts\ChangeNXOptInToOptOut.cmd"
CALL "%~dp0_Scripts\defrag in background.cmd"

:SchTasks
CALL "%~dp0_Scripts\Tasks\remove_old_Windows_Backups.cmd"
SET srcpath=
:PageFile
IF EXIST c:\WINDOWS\SwapSpace CALL "%~dp0_Scripts\pagefile_on_Windows_SwapSpace.cmd"
SET srcpath=

CALL "%~dp0_Scripts\HideShortcutsInAllUsersStartMenu.cmd"
CALL "%~dp0_Scripts\copyDefaultUserProfile.cmd"
REM Unpacking Desktop Shortcuts / Распаковка ярлыков на рабочий стол 
IF DEFINED ProfilesDirectory IF DEFINED DefaultUserProfile %exe7z% x -aoa -o"%ProfilesDirectory%\%DefaultUserProfile%\Desktop" -- "%~dp0_Scripts\Default User\office_shortcuts.7z"

rem Изменение пути профилей
MKDIR d:\Users
IF EXIST d:\Users %AutohotkeyExe% "%~dp0_Scripts\MoveUserProfile\SetProfilesDirectory_D_Users.ahk"
POWERCFG -h off & POWERCFG /H OFF

@ECHO Установка закончена. Окно остаётся открытым для возможности проверки журнала.
PAUSE
