@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
rem без прав администратора РАБОТАЕТ! %SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF NOT DEFINED ErrorCmd SET ErrorCmd=PAUSE

    SET "InstallUsername=Install"
    SET "PasswdPart1=0000%RANDOM%"
    SET "PasswdPart2=0000%RANDOM%"
    SET "lastTriedPass=*"
    SET "unpostedPass=tadFtCnyrpIeUWxQob00"
    SET "unpostedPassName=Пароль №287"

    CALL "%~dp0..\FindAutoHotkeyExe.cmd"
    IF EXIST "C:\Users\Install\Install-pwd.txt" (
	SET "PassFilePath=C:\Users\Install\Install-pwd.txt"
    ) ELSE SET "PassFilePath=%USERPROFILE%\Install-pwd.txt"

    FOR /F "usebackq tokens=2*" %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
)
(
    IF NOT EXIST "%ProgramData%\mobilmir.ru\trello-id.txt" %AutoHotkeyExe% "%~dp0..\Write-trello-id.ahk"
    
    SET "newPwd=%PasswdPart1:~-4%-%PasswdPart2:~-4%"
    SET "showPwd=%PasswdPart1:~-4%-%PasswdPart2:~-4%"
    IF NOT EXIST "%PassFilePath%" IF EXIST "%TEMP%\install-pwd.txt" ECHO Y|MOVE /Y "%TEMP%\install-pwd.txt" "%PassFilePath%"
    IF NOT EXIST "%PassFilePath%" IF EXIST "%PROGRAMDATA%\mobilmir.ru\install-pwd.txt" ECHO Y|MOVE /Y "%PROGRAMDATA%\mobilmir.ru\install-pwd.txt" "%PassFilePath%"
)
rem :CreateNewUser
%AutoHotkeyExe% "%~dp0AddUser_Install_PostPasswordToForm.ahk" "%InstallUsername%" "%showPwd%" "предварительная отправка (до смены пароля)" || (
    ECHO Отправка пароля в форму не удалась. Будет установлен пароль №287, смените его при первой возможности!
    SET "newPwd=%unpostedPass%"
    SET "showPwd=%unpostedPassName%"
)
(
    rem Check user existence
    "%SystemRoot%\System32\NET.exe" USER "%InstallUsername%" >NUL && GOTO :ExistingUser
    
    ECHO %InstallUsername%	%showPwd%	%DATE% %TIME% @%Hostname% Adding new user>>"%PassFilePath%"
    "%SystemRoot%\System32\NET.exe" USER "%InstallUsername%" "%newPwd%" /ADD >>"%PassFilePath%" 2>&1
    rem ERRORLEVEL=2 The account already exists.
    IF ERRORLEVEL 2 IF NOT ERRORLEVEL 3 GOTO :ExistingUser
    IF ERRORLEVEL 1 CALL :ErrorCreatingUser
    "%SystemRoot%\System32\NET.exe" LOCALGROUP Administrators %InstallUsername% /Add
    "%SystemRoot%\System32\NET.exe" LOCALGROUP Администраторы %InstallUsername% /Add

    IF EXIST "D:\Users\*.*" CALL "%~dp0..\FindAutoHotkeyExe.cmd" "%~dp0..\MoveUserProfile\SetProfilesDirectory_D_Users.ahk"

GOTO :ShowFileAndPostPassword
)
:ErrorCreatingUser
(
    ECHO error %ERRORLEVEL% adding user>>"%PassFilePath%"
    SET "InstallUsername=%InstallUsername%"
    SET "status=UserAdd Error %ERRORLEVEL%"
EXIT /B
)
:ExistingUser
(
    SET "findExeTestExecutionOptions=-?"
    CALL "%~dp0..\find_exe.cmd" passwdexe "%SystemRoot%\SysUtils\UnxUtils\Uri\passwd.exe" "%~dp0..\..\..\Programs\passwd.exe" \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Programs\passwd.exe || (
	ECHO passwd.exe not found. Trying to reset the password.
	GOTO :ExistingUserResetPwd
    )
    SET /A "TryNo=0"
)
:ExistingUserNextTry
(
SET "showOldPwd="
SET /A "TryNo+=1"
)
IF %TryNo% EQU 1 (
    rem Read last old password and username from the file OR try empty
    IF NOT EXIST "%PassFilePath%" GOTO :ExistingUserNextTry
    FOR /F "usebackq tokens=1,2 delims=	" %%I IN ("%PassFilePath%") DO IF "%%~I"=="%InstallUsername%" SET "OldPwd=%%~J"
) ELSE IF %TryNo% EQU 2 (
    rem Read each other password from the file
    IF EXIST "%PassFilePath%" FOR /F "usebackq tokens=1,2 delims=	" %%I IN ("%PassFilePath%") DO IF "%%~I"=="%InstallUsername%" IF NOT "%%~I"=="%OldPwd%" (
	SET "OldPwd=%%~J"
	CALL :ExistingUserChangePass && GOTO :ShowFileAndPostPassword 
    )
) ELSE IF %TryNo% EQU 3 (
    SET "OldPwd=1"
) ELSE IF %TryNo% EQU 4 (
    SET "showOldPwd=%unpostedPassName%"
    SET "OldPwd=%unpostedPass%"
) ELSE GOTO :ExistingUserResetPwd
(
    IF NOT DEFINED showOldPwd SET "showOldPwd=%OldPwd%"
    CALL :ExistingUserChangePass && GOTO :ShowFileAndPostPassword
    GOTO :ExistingUserNextTry
)   
:ExistingUserResetPwd
(
    SET "status=Сброс пароля"
    ECHO %InstallUsername%	%showPwd%	%DATE% %TIME% @%Hostname% Resetting user password>>"%PassFilePath%"
    "%SystemRoot%\System32\NET.exe" user "%InstallUsername%" "%newPwd%" >>"%PassFilePath%" 2>&1 && GOTO :ShowFileAndPostPassword
)
(
    SET "status=%Status%, LastError %ERRORLEVEL%"
    GOTO :ShowFileAndPostPassword
)
:ShowFileAndPostPassword
(
    START "" %AutoHotkeyExe% "%~dp0AddUser_Install_PostPasswordToForm.ahk" "%InstallUsername%" "%showPwd%" "%Status%"

    rem Копирование данных из профиля по умолчанию
    IF /I "%InstallUsername%" NEQ "%USERNAME%" EXIT /B
    START "" notepad.exe "%PassFilePath%"
    CALL "%~dp0..\find7zexe.cmd" || EXIT /B
)
(
    %exe7z% x -aoa -y -o"%APPDATA%" -- "%~dp0..\Default User\default_AppDataRoaming.7z"
    XCOPY "%~dp0..\..\Users\Default\*.*" "%USERPROFILE%" /E /I /Q /G /H /K /Y
EXIT /B %ERRORLEVEL%
)
:ExistingUserChangePass
(
    SET "lastError=32761"
    IF NOT "%lastTriedPass%"=="%OldPwd%" (
	SET "lastTriedPass=%OldPwd%"
	IF DEFINED OldPwd ( SET "status=Успешная смена пароля с '%showOldPwd%'" ) ELSE SET "status=Успешная смена пароля с пустого"
	ECHO %InstallUsername%	%showPwd%	%DATE% %TIME% @%Hostname% Changing password from "%showOldPwd%">>"%PassFilePath%"
	SET "lastError="
	%passwdexe% -u %InstallUsername% -c "%OldPwd%" "%newPwd%" >>"%PassFilePath%" 2>&1
	IF ERRORLEVEL 1 CALL :EchoPasswdExeError
    )
    IF NOT DEFINED lastError EXIT /B
)
EXIT /B %lastError%
:EchoPasswdExeError
(
    SET "lastError=%ERRORLEVEL%"
    SET "status=Ошибка %ERRORLEVEL% при попытке смены пароля с '%showOldPwd%'"
    (
	ECHO passwd.exe returned error %ERRORLEVEL%
    )>>"%PassFilePath%"
    EXIT /B %ERRORLEVEL%
    rem ERRORLEVELs:
    rem 53	Не найден сетевой путь.
)
