@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
%SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
)
(
    FOR /F "usebackq tokens=1,2* delims=	" %%A IN (`ECHO OFF ^& CALL "%~dp0..\FindAutoHotkeyExe.cmd" "%~dp0SelectUserFromList.ahk"`) DO (
        CALL "%~dp0CreateLocalUser.cmd" "%%~A" "%%~B" "%%~C"
    )
)
