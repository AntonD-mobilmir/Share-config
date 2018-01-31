@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
rem ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

rem Init
IF NOT DEFINED ErrorCmd SET "ErrorCmd=PAUSE"
IF NOT DEFINED GNUPGHOME (
    SET "RemoveGPGHomeTemp=1"
    SET "GNUPGHOME=%TEMP%\gnupg"
    MKDIR "%TEMP%\gnupg"
)
FOR /F "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
FOR /F "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Domain"`) DO SET "Domain=%%~J"
IF NOT DEFINED Domain FOR /F "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DhcpDomain"`) DO SET "Domain=%%~J"
rem Read file, and for each line add corresponding user
FOR /F "usebackq eol=; tokens=1,2,3,4* delims=	" %%I IN ("%~dpn0.txt") DO CALL :SetupAdmin "%%~I" "%%~J" "%%~K" "%%~L"
IF DEFINED RemoveGPGHomeTemp RD /S /Q "%TEMP%\gnupg"
IF NOT "%RunInteractiveInstalls%"=="0" START "" %SystemRoot%\System32\control.exe userpasswords2
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
    SET "gpgUserID=%~3"
    SET "SaveDir=%~4"
)
@(
    rem Check user existence
    NET USER "%NewUsername%" >NUL 2>&1 && EXIT /B
    IF DEFINED %NewUsername%_flags CALL :GetValue flags "%NewUsername%_flags"
    IF DEFINED flags CALL :ParseFlags
    IF DEFINED flag_n EXIT /B
    IF DEFINED flag_r (
	rem break if any of following users exist
	NET USER Пользователь >NUL 2>&1 && EXIT /B
	NET USER Продавец >NUL 2>&1 && EXIT /B
    )
    IF NOT DEFINED flag_f IF "%RunInteractiveInstalls%"=="0" EXIT /B
    IF NOT DEFINED flag_f CALL :AskCreateUser || EXIT /B
    IF DEFINED flag_p (
	%SystemRoot%\System32\net.exe USER "%NewUsername%" /ADD /LOGONPASSWORDCHG:NO /PASSWORDCHG:NO /PASSWORDREQ:NO /USERCOMMENT:"Пользователь создан %DATE% в %TIME% скриптом %~f0" /FULLNAME:"%FullName%"
	%SystemRoot%\System32\wbem\wmic.exe path Win32_UserAccount where Name='%NewUsername%' set PasswordExpires=false
	GOTO :setupgroups
    )
    
    IF DEFINED SaveDir IF EXIST "%SaveDir%" SET "dirPlainOut=%SaveDir%\%Hostname%"
    IF NOT DEFINED dirPlainOut SET "dirPlainOut=%TEMP%\%~n0.e"

    IF DEFINED gpgUserID (
	IF NOT DEFINED gpgexe CALL "%~dp0..\preparegpgexe.cmd"
	IF NOT DEFINED AutoHotkeyExe CALL "%~dp0..\FindAutoHotkeyExe.cmd"
	IF NOT DEFINED dirGPGout SET "dirGPGout=%ProgramData%\mobilmir.ru\%~n0"
    )

    REM IF NOT DEFINED flag_p
    rem Generate new password
    SET "PasswdPart1=0000%RANDOM%"
    SET "PasswdPart2=0000%RANDOM%"
    SET "PasswdPart3=0000%RANDOM%"
    rem if password is longer than 14 chars, NET USER /ADD asks stupid question
)
@(
    SET "pwd=%PasswdPart1:~-4%-%PasswdPart2:~-4%-%PasswdPart3:~-4%"
    SET "PasswdPart1="
    SET "PasswdPart2="
    SET "PasswdPart3="

    SET "outPlainFName=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2% %TIME::=% %RANDOM%.txt"
    IF NOT EXIST "%dirPlainOut%" MKDIR "%dirPlainOut%"
    IF NOT "%dirPlainOut:~0,2%"=="\\" %SystemRoot%\System32\cipher.exe /E "%dirPlainOut%"
    IF DEFINED gpgUserID (
	MKDIR "%dirGPGout%"
	SET gpgencOut="%dirGPGout%\%gpgUserID%.txt.gpg"
	SET gpgServerCopy="\\Srv0.office0.mobilmir\profiles$\Administrators\%NewUsername%@%Hostname%.%Domain% %DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2% %TIME::=% %RANDOM%.txt.gpg"
    )
)
@(
    SET "UserAddError="
    rem Create new user
    (
	rem Write password to file
	ECHO %Hostname%\%NewUsername%	%pwd%
	NET USER "%NewUsername%" "%pwd%" /ADD /LOGONPASSWORDCHG:YES /FULLNAME:"%FullName%" || CALL :SetUserAddError
    )>>"%dirPlainOut%\%outPlainFName%" 2>&1
    
    IF DEFINED gpgexe (
	DEL %gpgencOut% 2>NUL
	%gpgexe% --batch -a -r "%gpgUserID%" -o %gpgencOut% -e "%dirPlainOut%\%outPlainFName%"
	START "Copying gpg-encrypted password to Srv0" /MIN %comspec% /C "COPY /Y /B %gpgencOut% %gpgServerCopy%"
	IF NOT EXIST "%ProgramData%\mobilmir.ru\trello-id.txt" %AutoHotkeyExe% "%~dp0..\Write-trello-id.ahk"
	START "" %AutoHotkeyExe% "%~dp0Add_Admins_PostPasswordToForm.ahk" "%NewUsername%" %gpgencOut%
    )
)
:setupgroups
(
REM END IF [DEFINED flag_p]
    rem Add to admin group. Its name differs depending on Windows language.
    (
	NET LOCALGROUP Administrators "%NewUsername%" /Add
	NET LOCALGROUP Администраторы "%NewUsername%" /Add
	NET LOCALGROUP Users "%NewUsername%" /Delete
	NET LOCALGROUP Пользователи "%NewUsername%" /Delete
    ) >NUL 2>&1
    ENDLOCAL
    IF NOT [%AutoHotkeyExe%]==[] SET AutoHotkeyExe=%AutoHotkeyExe%
    IF NOT [%gpgexe%]==[] SET gpgexe=%gpgexe%
    IF NOT [%exe7z%]==[] SET exe7z=%exe7z%
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
    SET "flag_n="
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
    SET /P "doit=Создать пользователя %NewUsername% (%FullName%)? [0=N=нет, остальное = да]"
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
