@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

CALL "%~dp0FindAutoHotkeyExe.cmd"
SET "mtprofiledir=d:\Mail\Thunderbird\profile"
SET "GetSharedMailUserIdScript=%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
)
IF EXIST "%mtprofiledir%\prefs.js" (
    ECHO Общий профиль почты уже существует в %mtprofiledir%. Если необходимо создать его заново, сначала переименуйте или удалите существующую папку.
    PING 127.0.0.1 -n 10 >NUL
    EXIT /B
)
(
IF NOT EXIST "%GetSharedMailUserIdScript%" %AutohotkeyExe% /ErrorStdOut "%~dp0GUI\AcquireAndRecordMailUserId.ahk"
CALL "%GetSharedMailUserIdScript%"
IF NOT DEFINED MailUserId CALL :GetMailUserId
)
(
%AutohotkeyExe% /ErrorStdOut "%~dp0..\thunderbird\create_new_profile.ahk" %MailUserId% "%mtprofiledir%"
rem CALL "%mtprofiledir%\gnupg\linkthisdirtoprofile.cmd"
rem CALL "%mtprofiledir%\gnupg\gpggenkey-main.cmd" %MailUserId%
EXIT /B
)
:GetMailUserId
SET /P "MailUserId=Пользователь электронной почты (до @): "
(
ECHO SET "MailUserId=%MailUserId%">"%GetSharedMailUserIdScript%"
EXIT /B
)
