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
    CALL :SetOrAsk Note "Описание (см. trello.com/c/uJ4B9C7w)" "%~3"
)
(
    %SystemRoot%\System32\net.exe USER "%newUserName%" * /Add /FULLNAME:"%FullName%" /USERCOMMENT:"%Note%" || EXIT /B
    %SystemRoot%\System32\net.exe USER "%newUserName%" /LOGONPASSWORDCHG:NO
    %SystemRoot%\System32\net.exe LOCALGROUP "Пользователи удаленного рабочего стола" "%newUserName%" /Add
    %SystemRoot%\System32\net.exe LOCALGROUP "Remote Desktop Users" "%newUserName%" /Add
EXIT /B
)

:SetOrAsk <varName> <description> <value>
(
    IF NOT "%~3"=="" (
	SET "%~1=%~3"
    ) ELSE IF NOT "%RunInteractiveInstalls%"=="0" (
	SET /P "%~1=%~2: "
    ) ELSE EXIT /B 1
EXIT /B
)
