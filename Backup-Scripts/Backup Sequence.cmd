@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    CALL :findAutohotkeyExe || ECHO Authotkey not found!
    ECHO Starting backup %DATE% %TIME%
    SET "BackupsRoot=%USERPROFILE%\Dropbox\Backups"
)
(
rem FOR %%I IN ("%BackupsRoot%\Google Sites\export *.cmd") DO START "" /WAIT /B /D "%%~dpI" %comspec% /C "%%~fI"||CALL :EchoErrorLevel
START "" /D "%BackupsRoot%\Redbooth" %AutohotkeyExe% /ErrorStdOut "download lists.ahk" ||CALL :EchoErrorLevel
START "" /D "%BackupsRoot%\CloudFlare" %AutohotkeyExe% /ErrorStdOut "_backup.ahk" ||CALL :EchoErrorLevel
START "" /B /D "%BackupsRoot%\Trello" %comspec% /C "%BackupsRoot%\Trello\_run.cmd" ||CALL :EchoErrorLevel

FOR /D %%I IN ("%USERPROFILE%\Documents\Accounts\gpg-keys\auto-backup\*") DO MOVE /Y "%%~I" "d:\Users\LogicDaemon\Documents\Accounts\gpg-keys\auto-backup-moved\%%~nxI"

CALL "%LOCALAPPDATA%\Scripts\sync_%COMPUTERNAME%.cmd"

EXIT /B
)

:findAutohotkeyExe
    FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
(
    IF NOT EXIST %AutohotkeyExe% EXIT /B 1
EXIT /B
)
:GetFirstArg
(
    SET %1=%2
EXIT /B
)
:EchoErrorLevel
@(ECHO ERRORLEVEL: %ERRORLEVEL%
EXIT /B
)
