@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd" || (PAUSE & EXIT /B 32767)
MKDIR R:\Rarus
)
CALL :procconfig "%DefaultsSource%" || (PAUSE & EXIT /B 32767)
(
    CALL "%ConfigDir%_Scripts\CheckWinVer.cmd" 6 || GOTO :XP

    "%SystemRoot%\System32\schtasks.exe" /Delete /TN "mobilmir\backup_1S_base" /F
    FOR %%A IN ("%~dp0Tasks\backup_1S_base.xml") DO SET "backup_1S_baseVer=%%~tA"
    ECHO.|"%SystemRoot%\System32\schtasks.exe" /Create /TN "mobilmir.ru\backup_1S_base" /XML "%~dp0Tasks\backup_1S_base.xml" /F
    SET "status=%ERRORLEVEL%"

GOTO :PostForm
)
:XP
(
    %exe7z% x -aoa -o"%SystemRoot%\Tasks" "%srcpath%Tasks.7z" backup_1S_base.job
    FOR %%A IN ("%SystemRoot%\Tasks\backup_1S_base.job") DO SET "backup_1S_baseVer=%%~tA (XP)"
    ECHO.|"%SystemRoot%\System32\schtasks.exe" /Change /TN backup_1S_base /RU SYSTEM
    SET "status=%ERRORLEVEL%"
GOTO :PostForm
)
:procconfig <DefaultsSource>
(
    CALL "%~dp1_Scripts\find7zexe.cmd"
    SET "ConfigDir=%~dp1"
EXIT /B
)
:PostForm
(
    IF NOT DEFINED AutohotkeyExe CALL "%ConfigDir%_Scripts\FindAutoHotkeyExe.cmd"
    IF NOT DEFINED MailUserId CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
    IF NOT DEFINED Hostname FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
)
(
    START "" %AutohotkeyExe% "%ConfigDir%_Scripts\Lib\PostGoogleForm.ahk" "https://docs.google.com/a/mobilmir.ru/forms/d/e/1FAIpQLScNLElrGY648SPbajjUiPXLZQrkV-b_B9P6S_KQ-4hIUJVf7A/formResponse" "entry.770894341=%Hostname%" "entry.2094511279=%MailUserId%" "entry.1062773648=%backup_1S_baseVer%" "entry.1644489156=%status%"
EXIT /B
)
