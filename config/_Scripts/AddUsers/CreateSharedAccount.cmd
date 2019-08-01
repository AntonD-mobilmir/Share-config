@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
%SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )

    CALL :SetOrAsk newUserName "Имя пользователя (логин)" "%~1"
    CALL :SetOrAsk FullName "Назначение учётной записи (Полное имя)" "%~2"
    REM "Описание (номер заявки / см. trello.com/c/ov1INOPm/15)"
    SET "Note=%~3" 
    IF NOT DEFINED Note SET "Note=Учетная запись создана %DATE% %TIME% пользователем %USERNAME%"
    
    SET "passwordFile=%~4"
    IF NOT DEFINED passwordFile SET "passwordFile=NUL"
)
(
    TYPE "%passwordFile%"|%SystemRoot%\System32\net.exe USER "%newUserName%" * /Add /FULLNAME:"%FullName%" /USERCOMMENT:"%Note%" /passwordchg:no /passwordreq:no || EXIT /B
    %SystemRoot%\System32\wbem\wmic.exe path Win32_UserAccount where Name='%newUserName%' set PasswordExpires=false
    
    IF EXIST "D:\Users\*.*" CALL "%~dp0..\FindAutoHotkeyExe.cmd" "%~dp0..\MoveUserProfile\SetProfilesDirectory_D_Users.ahk"
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
