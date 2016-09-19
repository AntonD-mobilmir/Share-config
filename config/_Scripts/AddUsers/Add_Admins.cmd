@REM coding:OEM
@ECHO OFF
SETLOCAL
rem Init
IF NOT DEFINED ErrorCmd SET ErrorCmd=PAUSE
FOR /F "usebackq tokens=2*" %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
rem Find AutoHotkey interpreter
CALL "%~dp0..\FindAutoHotkeyExe.cmd"

rem Read file, and for each line add corresponding user
FOR /F "usebackq eol=; tokens=1,2,3* delims=	" %%I IN ("%~dpn0_list.txt") DO CALL :SetupAdmin "%%~I" "%%~J" "%%~K" "%%~L"
EXIT /B

:SetupAdmin
    (
    SETLOCAL
    SET NewUsername=%~1
    SET /A postmethodscounter=0
    )
    IF DEFINED %NewUsername%_flag (
	CALL :GetValue flag "%NewUsername%_flag"
    ) ELSE IF "%NewUsername:~-2,-1%"=="/" (
	SET flag=%NewUsername:~-1%
	SET NewUsername=%NewUsername:~0,-2%
    )
    IF "%flag%"=="r" (
	rem If any of following users exist, skip this one
	NET USER Пользователь >NUL 2>&1 && EXIT /B
	NET USER Продавец >NUL 2>&1 && EXIT /B
    )
    (
    SET "FullName=%~2"
    SET "URL=%~3"
    IF NOT "%~3"=="" SET /A postmethodscounter+=1
    SET "Dir=%~4"
    IF NOT "%~4"=="" SET /A postmethodscounter+=1
    rem Check user existence
    NET USER %NewUsername% >NUL 2>&1 && EXIT /B
    )
    (
    IF %postmethodscounter% EQU 0 SET "addtext= без пароля"
    IF NOT "%flag%"=="f" SET /P doit=Создать пользователя %NewUsername% ^(%FullName%^)%addtext%? [0=N=нет]
    )
    (
    SET OutDir=%Dir%\%Hostname%
    IF "%doit%"=="0" EXIT /B
    IF /I "%doit:~0,1%" EQU "n" EXIT /B
    IF /I "%doit:~0,1%" EQU "н" EXIT /B
    )
    IF %postmethodscounter% EQU 0 GOTO :nopassword
    (
    rem Generate new password
    SET PasswdPart1=0000%RANDOM%
    SET PasswdPart2=0000%RANDOM%
    SET PasswdPart3=0000%RANDOM%
    )
    (
    SET pwd=%PasswdPart1:~-4%-%PasswdPart2:~-4%-%PasswdPart3:~-4%
    rem if password is longer than 14 chars, NET USER /ADD asks stupid question
    )
    (
    rem Create new user
    NET USER %NewUsername% %pwd% /ADD /LOGONPASSWORDCHG:YES /FULLNAME:"%FullName%"
    IF ERRORLEVEL 1 SET "PostUsername=%NewUsername% \\ UserAddError=%ERRORLEVEL%"
    )
    (
    rem ERRORLEVEL=2 The account already exists.
    rem    IF "%ERRORLEVEL%"=="2" EXIT /B
    rem Post password in background
    START "" %AutoHotkeyExe% "%~dp0..\Lib\HTTP_POST.ahk" https://zapier.com/hooks/catch/b5lm1r/ "Host=%Hostname%&UserName=%PostUsername%&Pwd=%pwd%"
    rem Write password to file
    MKDIR "%OutDir%" 2>NUL
    ECHO %Hostname%	%PostUsername%	%pwd%>>"%OutDir%\%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2% %TIME::=% %RANDOM%.txt"
    )
:setupgroups
    (
    rem Add to admin group. Its name differs depending on Windows language.
    NET LOCALGROUP Users %NewUsername% /Delete >NUL 2>&1
    NET LOCALGROUP Пользователи %NewUsername% /Delete >NUL 2>&1
    NET LOCALGROUP Administrators %NewUsername% /Add >NUL 2>&1
    NET LOCALGROUP Администраторы %NewUsername% /Add >NUL 2>&1
    ENDLOCAL
    )
EXIT /B
:nopassword
    NET USER %NewUsername% /ADD /LOGONPASSWORDCHG:NO /PASSWORDCHG:NO /PASSWORDREQ:NO /FULLNAME:"%FullName%"
    wmic path Win32_UserAccount where Name='%NewUsername%' set PasswordExpires=false
GOTO :setupgroups

:GetValue <targetvarname> <sourcevarname>
    FOR /F "delims=" %%I IN ("%~2") DO SET "%~2=%%~I"
EXIT /B
