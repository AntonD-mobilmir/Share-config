@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"
    
    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
    FOR /F "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
    IF NOT DEFINED MailUserId CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
    
    FOR %%A IN ("%ProgramData%" "%LOCALAPPDATA%") DO (
        SET "scriptConfDir=%%~A\mobilmir.ru\%~n0"
        DEL /F "%%~A\mobilmir.ru\%~n0\test.tmp"
        IF NOT EXIST "%%~A\mobilmir.ru\%~n0\test.tmp" (
            IF NOT EXIST "%%~A\mobilmir.ru\%~n0" MKDIR "%%~A\mobilmir.ru\%~n0"
            ECHO.>"%%~A\mobilmir.ru\%~n0\test.tmp"
            IF EXIST "%%~A\mobilmir.ru\%~n0\test.tmp" (
                DEL /F "%%~A\mobilmir.ru\%~n0\test.tmp"
                GOTO :FindScriptUpdaterDir
            )
        )
    )
    ECHO Не удалось найти папку для записи состояния скрипта.
    EXIT /B 1
)
:FindScriptUpdaterDir
(
    FOR /F "usebackq delims=" %%A IN ("%ProgramData%\mobilmir.ru\ScriptUpdaterDir.txt") DO SET "ScriptUpdaterDir=%%~A"
    IF NOT DEFINED ScriptUpdaterDir (
        ECHO "%ProgramData%\mobilmir.ru\ScriptUpdaterDir.txt" не существует, либо нет доступа для чтения.
	rem %SystemRoot%\System32\fltmc.exe >nul 2>&1 || (ECHO Чтобы установить ScriptUpdater, нужны права администратора & EXIT /B)
	rem CALL "%~dp0..\ScriptUpdater_dist\InstallScriptUpdater.cmd"
	rem GOTO :FindScriptUpdaterDir
	EXIT /B 1
    )
    
    CALL :GetDir configDir "%DefaultsSource%"
    
    SET "foundShortcuts="
    FOR /D %%A IN ("%~dp0Shortcuts\*.*") DO IF EXIST "%%~A\*.lnk" SET "foundShortcuts=1"
    IF DEFINED foundShortcuts FOR /F "usebackq delims=" %%A IN ("%scriptConfDir%\lastUnpacked.txt") DO IF DEFINED lastShortcutsTime (SET "lastShortcuts_64bitTime=%%~A") ELSE SET "lastShortcutsTime=%%~A"
)
(
    IF NOT DEFINED AutohotkeyExe CALL "%configDir%_Scripts\FindAutoHotkeyExe.cmd"
    rem IF NOT DEFINED SetACLexe CALL "%configDir%_Scripts\find_exe.cmd" SetACLexe SetACL.exe
)
(
    %AutohotkeyExe% /ErrorStdOut "%ScriptUpdaterDir%\scriptUpdater.ahk" "%configDir%Users\depts\Shortcuts.7z" "https://www.dropbox.com/s/hc73p6v080ffajy/Shortcuts.7z.gpg?dl=1"
    FOR %%A IN ("%configDir%Users\depts\Shortcuts.7z") DO IF NOT "%lastShortcutsTime%"=="%%~tA" SET "ShortcutsTime=%%~tA"
    IF DEFINED OS64bit (
	%AutohotkeyExe% "%ScriptUpdaterDir%\scriptUpdater.ahk" /ErrorStdOut "%configDir%Users\depts\Shortcuts_64bit.7z" https://www.dropbox.com/s/0hhm20a0oemp1m9/Shortcuts_64bit.7z.gpg?dl=1
	FOR %%A IN ("%configDir%Users\depts\Shortcuts_64bit.7z") DO IF NOT "%lastShortcuts_64bitTime%"=="%%~tA" SET "Shortcuts_64bitTime=%%~tA"
    )
    
    IF NOT DEFINED ShortcutsTime IF NOT DEFINED Shortcuts_64bitTime (
	ECHO Даты архивов не изменились, выход
	EXIT /B
    )
    
    IF NOT DEFINED exe7z CALL "%configDir%_Scripts\find7zexe.cmd"
    
    CALL :unpack7zs "%~dp0Shortcuts.new"
    REM Удаление файлов, которых нет в новом архиве
    FOR /F "usebackq delims=" %%A IN (`DIR /B /A-D "%~dp0Shortcuts\*.*"`) DO IF NOT EXIST "%~dp0Shortcuts.new\%%~A" ECHO.|DEL /F "%~dp0Shortcuts\%%~A"
    REM Файлов в подпапках может не быть новых архивах, проверить в пакетном файле это будет сложно
    FOR /F "usebackq delims=" %%A IN (`DIR /B /AD "%~dp0Shortcuts\*.*"`) DO RD /S /Q "%~dp0Shortcuts\%%~A"
    REM проще и быстрее распаковать заново, чем переместить
    RD /S /Q "%~dp0Shortcuts.new"
    CALL :unpack7zs "%~dp0Shortcuts"
    
    CALL :UpdatelastUnpackedtxt
    
    %AutohotkeyExe% "%ScriptUpdaterDir%\scriptUpdater.ahk" /ErrorStdOut "%~f0"
    EXIT /B
)
:unpack7zs <dest>
(
    %exe7z% x -aoa -o%1 -- "%configDir%Users\depts\Shortcuts.7z" >"%scriptConfDir%\unpack-Shortcuts.7z.log" 2>&1 || CALL :SaveErrorLevel unpacking Shortcuts.7z to %1
    IF DEFINED Shortcuts_64bitTime %exe7z% x -aoa -o%1 -- "%configDir%Users\depts\Shortcuts_64bit.7z" >"%scriptConfDir%\unpack-Shortcuts_64bit.7z.log" 2>&1 || CALL :SaveErrorLevel unpacking Shortcuts_64bit.7z
EXIT /B
)
:UpdatelastUnpackedtxt
(
    START "" %AutohotkeyExe% "%configDir%_Scripts\Lib\PostGoogleForm.ahk" "https://docs.google.com/forms/d/e/1FAIpQLSeRCnfwwNbKEruCW0ALmzsXvF9oRhm9MHe95qOleKzqrbpp7A/formResponse" "entry.48561467=%MailUserId%" "entry.1166115539=%Hostname%" "entry.2076050092=%ShortcutsTime%" "entry.1752683108=%Shortcuts_64bitTime%" "entry.1722862426=%savedErrors%" "entry.1400183939=%USERNAME% (up from %lastShortcutsTime%/%lastShortcuts_64bitTime%)"

    IF NOT DEFINED ShortcutsTime SET "ShortcutsTime=%lastShortcutsTime%"
    IF NOT DEFINED Shortcuts_64bitTime SET "Shortcuts_64bitTime=%lastShortcuts_64bitTime%"
)
@(
    (
        IF DEFINED ShortcutsTime (ECHO %ShortcutsTime%) ELSE ECHO.
        IF DEFINED Shortcuts_64bitTime (ECHO %Shortcuts_64bitTime%) ELSE ECHO.
    )>"%scriptConfDir%\lastUnpacked.txt"
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
