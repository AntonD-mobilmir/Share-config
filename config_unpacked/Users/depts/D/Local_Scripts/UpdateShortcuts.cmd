@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
IF NOT DEFINED MailUserId CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
)
CALL :GetDir configDir "%DefaultsSource%"
(
IF NOT DEFINED exe7z CALL "%configDir%_Scripts\find7zexe.cmd"
IF NOT DEFINED AutohotkeyExe CALL "%~dp0FindAutoHotkeyExe.cmd"
rem IF NOT DEFINED SetACLexe CALL "%configDir%_Scripts\find_exe.cmd" SetACLexe SetACL.exe
)
(
    RD /S /Q "%~dp0Shortcuts" || CALL :SaveErrorLevel cleaning up old Shortcuts
    %exe7z% x -aoa -o"%~dp0Shortcuts" -- "%configDir%Users\depts\Shortcuts.7z" || CALL :SaveErrorLevel unpacking Shortcuts.7z
    IF "%OS64bit%"=="1" %exe7z% x -aoa -o"%~dp0Shortcuts" -- "%configDir%Users\depts\Shortcuts_64bit.7z" || CALL :SaveErrorLevel unpacking Shortcuts_64bit.7z
    
    FOR %%A IN ("%~dp0Shortcuts.7z") DO SET "ShortcutsTime=%%~tA"
    FOR %%A IN ("%~dp0Shortcuts_64bit.7z") DO SET "Shortcuts_64bitTime=%%~tA"
    CALL :PostForm

    %AutohotkeyExe% "%configDir%\_Scripts\scriptUpdater.ahk" "%~f0"
    EXIT /B
)
:PostForm
(
    START "" %AutohotkeyExe% "%~dp0Lib\PostGoogleForm.ahk" "https://docs.google.com/forms/d/e/1FAIpQLSeNftB3Rwx9ztsZn6FD3mHbAOR87-nxPMaeSle80obZAIR3TQ/formResponse" "entry.48561467=%MailUserId%" "entry.1166115539=%Hostname%" "entry.2076050092=%ShortcutsTime%" "entry.1752683108=%Shortcuts_64bitTime%" "entry.1722862426=%savedErrors%"
EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
:SaveErrorLevel
(
    IF DEFINED savedErrors (
	SET savedErrors=%savedErrors%, %*: %ERRORLEVEL%
    ) ELSE (
	SET savedErrors=%*: %ERRORLEVEL%
    )
    EXIT /B
)
