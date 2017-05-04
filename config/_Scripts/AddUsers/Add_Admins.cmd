@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

rem Init
IF NOT DEFINED ErrorCmd SET "ErrorCmd=PAUSE"
FOR /F "usebackq tokens=2*" %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
rem Read file, and for each line add corresponding user
FOR /F "usebackq eol=; tokens=1,2,3* delims=	" %%I IN ("%~dpn0_list.txt") DO CALL :SetupAdmin "%%~I" "%%~J" "%%~K" "%%~L"
IF NOT "%RunInteractiveInstalls%"=="1" START "" control.exe userpasswords2
EXIT /B
)
:SetupAdmin
(
    SETLOCAL ENABLEEXTENSIONS
    FOR /F "delims=/ tokens=1*" %%A IN ("%~1") DO (
	SET "NewUsername=%%~A"
	SET "flags=%%~B"
    )
    SET "FullName=%~2"
    SET "SaveDir=%~3"
    SET "URL=%~4"
)
(
    rem Check user existence
    NET USER "%NewUsername%" >NUL 2>&1 && EXIT /B
    IF DEFINED %NewUsername%_flags CALL :GetValue flags "%NewUsername%_flags"
    IF DEFINED flags CALL :ParseFlags
    IF DEFINED flag_r (
	rem break if any of following users exist
	NET USER Пользователь >NUL 2>&1 && EXIT /B
	NET USER Продавец >NUL 2>&1 && EXIT /B
    )
    IF NOT DEFINED flag_f CALL :AskCreateUser || EXIT /B
    IF DEFINED flag_p (
	NET USER %NewUsername% /ADD /LOGONPASSWORDCHG:NO /PASSWORDCHG:NO /PASSWORDREQ:NO /FULLNAME:"%FullName%"
	wmic.exe path Win32_UserAccount where Name='%NewUsername%' set PasswordExpires=false
	GOTO :setupgroups
    )

    IF DEFINED SaveDir SET "OutDir=%SaveDir%\%Hostname%"
    IF DEFINED URL IF NOT DEFINED AutoHotkeyExe CALL "%~dp0..\FindAutoHotkeyExe.cmd"
    
    rem Generate new password
    SET "PasswdPart1=0000%RANDOM%"
    SET "PasswdPart2=0000%RANDOM%"
    SET "PasswdPart3=0000%RANDOM%"
    rem if password is longer than 14 chars, NET USER /ADD asks stupid question
)
SET "pwd=%PasswdPart1:~-4%-%PasswdPart2:~-4%-%PasswdPart3:~-4%"
(
    SET "UserAddError="
    rem Create new user
    IF DEFINED OutDir (
	MKDIR "%OutDir%" 2>NUL
	(
	    rem Write password to file
	    ECHO %Hostname%\%NewUsername%	%pwd%
	    NET USER "%NewUsername%" "%pwd%" /ADD /LOGONPASSWORDCHG:YES /FULLNAME:"%FullName%" || CALL :SetUserAddError
	)>>"%OutDir%\%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2% %TIME::=% %RANDOM%.txt" 2>&1
    )
)
(
    rem Post password in background
    IF DEFINED URL START "" %AutoHotkeyExe% "%~dp0..\Lib\XMLHTTP_POST.ahk" "%URL%" "Host=%Hostname%" "UserName=%NewUsername%" "Pwd=%pwd%" "UserAddError=%UserAddError%"
)
:setupgroups
(
    rem Add to admin group. Its name differs depending on Windows language.
    NET LOCALGROUP Users %NewUsername% /Delete >NUL 2>&1
    NET LOCALGROUP Пользователи %NewUsername% /Delete >NUL 2>&1
    NET LOCALGROUP Administrators %NewUsername% /Add >NUL 2>&1
    NET LOCALGROUP Администраторы %NewUsername% /Add >NUL 2>&1
    ENDLOCAL
    SET AutoHotkeyExe=%AutoHotkeyExe%
EXIT /B
)
:GetValue <targetvarname> <sourcevarname>
(
    FOR /F "usebackq delims=" %%I IN (`ECHO %%%~2%%`) DO SET "%~1=%%~I"
EXIT /B
)
:ParseFlags
(
    SET /A "i=0"
    REM reset flags
    SET "flag_f="
    SET "flag_p="
    SET "flag_r="
)
:ParseNextFlag
(
    SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
    SET "curFlag=!flags:~%i%,1!"
)
(
    ENDLOCAL
    IF "%curFlag%"=="" EXIT /B
    IF NOT DEFINED flag_%curFlag% SET "flag_%curFlag%=1"
    SET /A "i+=1"
    GOTO :ParseNextFlag
)
:AskCreateUser
    SET /P "doit=Создать пользователя %NewUsername% (%FullName%)? [0=N=нет]"
(
    IF "%doit%"=="0" EXIT /B 1
    IF /I "%doit:~0,1%" EQU "n" EXIT /B 1
    IF /I "%doit:~0,1%" EQU "н" EXIT /B 1
EXIT /B 0
)
:SetUserAddError
(
    rem ERRORLEVEL:
    rem 2	The account already exist
    SET "UserAddError=%ERRORLEVEL%"
EXIT /B
)
