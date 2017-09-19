@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
)
CALL :GetDir ConfigDir "%DefaultsSource%"
(
IF NOT DEFINED exe7z CALL "%ConfigDir%_Scripts\find7zexe.cmd"
rem IF NOT DEFINED SetACLexe CALL "%ConfigDir%_Scripts\find_exe.cmd" SetACLexe SetACL.exe
IF NOT DEFINED AutohotkeyExe CALL "%configDir%_Scripts\FindAutoHotkeyExe.cmd"
)
(
SET "GenKeyring="
FOR %%A IN ("%~dp0gnupg\secring.gpg") DO  (
    IF NOT EXIST "%%~A" SET "GenKeyring=1"
    IF %%~zA. EQU 0. SET "GenKeyring=1"
)
IF DEFINED GenKeyring CALL "%~dp0genGpgKeyring.cmd"

%AutohotkeyExe% /ErrorStdOut "%ConfigDir%_Scripts\scriptUpdater.ahk" >"%TEMP%\scriptUpdater.ahk.log" 2>&1
%exe7z% x -y -o"D:\" "%TEMP%\scriptUpdater.ahk.tmp\ScriptUpdater.7z"
IF EXIST D:\1S\Rarus\MailLoader (
    %AutohotkeyExe% /ErrorStdOut "%ConfigDir%_Scripts\scriptUpdater.ahk" "D:\1S\Rarus\MailLoader\*" "https://www.dropbox.com/s/ylkktduk9ybxjjg/MailLoader-dist.7z.gpg?dl=1" 168 >"%TEMP%\MailLoader-dist.7z.log" 2>&1
    %exe7z% x -y -o"D:\1S\Rarus\MailLoader\" "%TEMP%\scriptUpdater.ahk.tmp\MailLoader-dist.7z"
)

CALL "%~dp0..\UpdateShortcuts.cmd"
EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
