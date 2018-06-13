@(REM coding:CP866
rem user named admin-task-scheduler with random password, write password to an encrypted local file, use this password for tasks creation
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
    %SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

    IF NOT DEFINED ErrorCmd SET "ErrorCmd=ECHO "
    SET "PasswdPart1=0000%RANDOM%"
    SET "PasswdPart2=0000%RANDOM%"
    SET "PasswdPart3=0000%RANDOM%"

    SET "ManagedUserName=admin-task-scheduler"
)
SET "PassFileDir=%PROGRAMDATA%\mobilmir.ru"
@(
SET "newuserpwd=%PasswdPart1:~-4%-%PasswdPart2:~-4%.%PasswdPart3:~-4%"
SET "PasswdPart1="
SET "PasswdPart2="
SET "PasswdPart3="
IF NOT EXIST "%PassFileDir%" MKDIR "%PassFileDir%"
SET "PassFilePath=%PassFileDir%\admin-task-scheduler-pwd.txt"

IF "%~1"=="/LeaveExistingPwd" SET "LeaveExistingPwd=1"
)
(
rem Read old password and username from the file
IF EXIST "%PassFilePath%" FOR /F "usebackq tokens=1,2 delims=	" %%I IN ("%PassFilePath%") DO IF "%%~I"=="%ManagedUserName%" (
    IF NOT "%%~J"=="" SET "OldPwd=%%~J"
)
rem Check user existence
"%SystemRoot%\System32\NET.exe" USER "%ManagedUserName%">NUL && GOTO :ExistingUser
)
:CreateNewUser
@(
    DEL /F /A "%PassFilePath%"
    ECHO %ManagedUserName%	%newuserpwd%	%DATE% %TIME% Adding new user>"%PassFilePath%"
    "%SystemRoot%\System32\NET.exe" USER "%ManagedUserName%" "%newuserpwd%" /ADD >>"%PassFilePath%" 2>&1
    rem ERRORLEVEL=2 The account already exists.
    IF ERRORLEVEL 2 IF NOT ERRORLEVEL 3 GOTO :ExistingUser
)
(
    IF ERRORLEVEL 1 ECHO error %ERRORLEVEL% adding user>>"%PassFilePath%"
    "%SystemRoot%\System32\NET.exe" LOCALGROUP Administrators "%ManagedUserName%" /ADD >>"%PassFilePath%" 2>&1
    "%SystemRoot%\System32\NET.exe" LOCALGROUP Администраторы "%ManagedUserName%" /ADD >>"%PassFilePath%" 2>&1
    "%SystemRoot%\System32\NET.exe" LOCALGROUP Users "%ManagedUserName%" /DELETE >>"%PassFilePath%" 2>&1
    "%SystemRoot%\System32\NET.exe" LOCALGROUP Пользователи "%ManagedUserName%" /DELETE >>"%PassFilePath%" 2>&1

    IF NOT "%ImportSecPol%"=="0" CALL :ImportSecPol
GOTO :SetVarsAndExit
)
:ExistingUser
@(
    IF NOT DEFINED OldPwd GOTO :ExistingUserResetPwd
    IF "%LeaveExistingPwd%"=="1" (
	ENDLOCAL
	SET "schedUserPwd=%OldPwd%"
	SET "schedUserName=%ManagedUserName%"
	EXIT /B
    )
    SET "findExeTestExecutionOptions=-?"
    CALL "%~dp0..\find_exe.cmd" passwdexe "%SystemRoot%\SysUtils\UnxUtils\Uri\passwd.exe" "%~dp0..\..\..\Programs\passwd.exe" "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Programs\passwd.exe" || (
        ECHO passwd.exe not found. Trying to reset the password.
        GOTO :ExistingUserResetPwd
    )
)
(
    ECHO %ManagedUserName%	%newuserpwd%	%DATE% %TIME% Changing user password from "%OldPwd%">"%PassFilePath%"
    %passwdexe% -u "%ManagedUserName%" -c "%OldPwd%" "%newuserpwd%">>"%PassFilePath%" 2>&1
    IF NOT ERRORLEVEL 1 GOTO :SetVarsAndExit
    rem ERRORLEVELs:
    rem 4	invalid password
    rem 53	Не найден сетевой путь.
)
    ECHO error %ERRORLEVEL% changing password, will try to reset>>"%PassFilePath%"
:ExistingUserResetPwd
@(
    DEL /F /A "%PassFilePath%"
    ECHO "%ManagedUserName%"	%newuserpwd%	%DATE% %TIME% Resetting password>"%PassFilePath%"
    "%SystemRoot%\System32\NET.exe" USER "%ManagedUserName%" %newuserpwd%>>"%PassFilePath%" 2>&1
GOTO :SetVarsAndExit
)
:SetVarsAndExit
@(
    "%SystemRoot%\System32\CIPHER.exe" /E "%PassFilePath%"
    ENDLOCAL
    SET "schedUserPwd=%newuserpwd%"
    SET "schedUserName=%ManagedUserName%"
    EXIT /B
)
:ImportSecPol
(
    SET "seceddb=%SystemRoot%\security\Database\secedit.sdb"
    SET "localfsSecInf=%TEMP%\%~n0 secpol.inf"
)
(
    IF NOT EXIST "%seceddb%.bak%DATE%" COPY /Y /B "%seceddb%" "%seceddb%.bak%DATE%"
    COPY /Y /B "%seceddb%" "%seceddb%.new"
    REM копировать скрипт .inf в %TEMP%, иначе Win7 не может импортировать политику, поскольку не может получить доступ в сеть
    COPY /B /Y "%~dpn0 secpol.inf" "%localfsSecInf%"
    "%SystemRoot%\System32\secedit.exe" /configure /db "%seceddb%.new" /cfg "%localfsSecInf%"||%ErrorCmd%
rem     MOVE /Y "%seceddb%.new" "%seceddb%"
    DEL "%localfsSecInf%"
EXIT /B
)
