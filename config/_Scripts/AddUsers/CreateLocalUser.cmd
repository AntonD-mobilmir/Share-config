@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
%SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    CALL :SetOrAsk newUserName "Имя пользователя (логин)" "%~1"
    CALL :SetOrAsk FullName "Полное имя (ФИО по-русски)" "%~2"
    SET "Note=%~3"
    REM CALL :SetOrAsk Note "Описание (см. trello.com/c/uJ4B9C7w)" "%~3"
    
    SET "ErrAcc="
    SET "useradderr="
)
(
    %SystemRoot%\System32\net.exe USER "%newUserName%" * /Add /FULLNAME:"%FullName%" /USERCOMMENT:"%Note%" || CALL :AccumulateError "net user /Add" erruseradd
    %SystemRoot%\System32\net.exe USER "%newUserName%" /LOGONPASSWORDCHG:NO || CALL :AccumulateError "/LOGONPASSWORDCHG:NO"
    %SystemRoot%\System32\net.exe LOCALGROUP "Пользователи удаленного рабочего стола" "%newUserName%" /Add || CALL :AccumulateError "LOCALGROUP Пользователи удаленного рабочего стола"
    %SystemRoot%\System32\net.exe LOCALGROUP "Remote Desktop Users" "%newUserName%" /Add || CALL :AccumulateError "LOCALGROUP Remote Desktop Users"
    
    IF EXIST "D:\Users\*.*" CALL "%~dp0..\FindAutoHotkeyExe.cmd" "%~dp0..\MoveUserProfile\SetProfilesDirectory_D_Users.ahk"
    IF NOT DEFINED useradderr EXIT /B
)
(
    ECHO %ErrAcc%
EXIT /B %erruseradd%
)

:AccumulateError <textname> [<varname>]
(
    SET "ErrAcc=%ErrAcc% %~1: err %ERRORLEVEL%"
    IF "%~2"=="" EXIT /B
    SET "%2=%ERRORLEVEL%"
EXIT /B
)

:SetOrAsk <varName> <description> <value>
(
    IF NOT DEFINED Unattended IF "%RunInteractiveInstalls%"=="0" SET "Unattended=1"
    IF NOT "%~3"=="" (
	SET "%~1=%~3"
    ) ELSE IF NOT DEFINED Unattended (
	SET /P "%~1=%~2: "
    ) ELSE EXIT /B 1
EXIT /B
)
