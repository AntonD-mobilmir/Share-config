@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    SETLOCAL ENABLEEXTENSIONS
    %SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )
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
    CALL "%~dp0..\FindAutoHotkeyExe.cmd"

    rem Read file, and for each line add corresponding user
    FOR /F "usebackq eol=; tokens=1,2,3,4* delims=	" %%I IN ("%~dpn0.txt") DO CALL :SetupAdmin "%%~I" "%%~J" "%%~K" "%%~L"
    IF DEFINED RemoveGPGHomeTemp RD /S /Q "%TEMP%\gnupg"
    IF NOT DEFINED Unattended IF "%RunInteractiveInstalls%"=="0" SET "Unattended=1"
    IF NOT DEFINED Unattended START "" %SystemRoot%\System32\control.exe userpasswords2
)
(
IF DEFINED AutoHotkeyExe IF NOT EXIST "%ProgramData%\mobilmir.ru\trello-id.txt" %AutoHotkeyExe% "%~dp0..\Write-trello-id.ahk"
EXIT /B
)
:SetupAdmin <username/flags> <fullName> <gpgUserID> <DirForPlaintext>
(
    SETLOCAL ENABLEEXTENSIONS
    FOR /F "delims=/ tokens=1*" %%A IN ("%~1") DO (
	SET "newUsername=%%~A"
	SET "flags=%%~B"
    )
    SET "fullName=%~2"
    SET "gpgUserID=%~3"
    SET "saveDir=%~4"
)
@(
    rem Check user existence
    NET USER "%newUsername%" >NUL 2>&1 && EXIT /B
    IF DEFINED %newUsername%_flags CALL :GetValue flags "%newUsername%_flags"
    IF DEFINED flags CALL :ParseFlags
    IF DEFINED flag_n EXIT /B
    IF DEFINED flag_r (
	rem break if any of following users exist
	NET USER Пользователь >NUL 2>&1 && EXIT /B
	NET USER Продавец >NUL 2>&1 && EXIT /B
    )
    IF NOT DEFINED flag_f IF DEFINED Unattended EXIT /B
    IF NOT DEFINED flag_f CALL :AskCreateUser || EXIT /B
    IF DEFINED flag_p (
	%SystemRoot%\System32\net.exe USER "%newUsername%" /ADD /LOGONPASSWORDCHG:NO /PASSWORDCHG:NO /PASSWORDREQ:NO /USERCOMMENT:"Пользователь создан %DATE% в %TIME% скриптом %~f0" /fullName:"%fullName%"
	%SystemRoot%\System32\wbem\wmic.exe path Win32_UserAccount where Name='%newUsername%' set PasswordExpires=false
	GOTO :setupgroups
    )
    
    IF DEFINED saveDir IF EXIST "%saveDir%" SET "dirPlainOut=%saveDir%\%Hostname%"
    IF NOT DEFINED dirPlainOut SET "dirPlainOut=%TEMP%\%~n0.e"
    
    SET "dirGPGout="
    IF DEFINED gpgUserID (
	IF NOT DEFINED gpgexe CALL "%~dp0..\preparegpgexe.cmd"
	IF DEFINED gpgexe SET "dirGPGout=%ProgramData%\mobilmir.ru\%~n0"
    )
    
    REM IF NOT DEFINED flag_p
    rem Generate new password
    SET "newPasswd="
    rem since Autohotkey is quoted, and FOR uses CMD /C syntax, another set of quotes required around whole command including parameters
    IF DEFINED AutoHotkeyExe FOR /F "usebackq delims=" %%A IN (`"%AutoHotkeyExe% "%~dp0..\Lib\GenPassword.ahk""`) DO @IF NOT DEFINED newPasswd SET "newPasswd=%%~A"
    IF NOT DEFINED newPasswd SET /A "PasswdPart1=%RANDOM% * 10000 / 32767" & SET /A "PasswdPart2=%RANDOM% * 10000 / 32767" & SET /A "PasswdPart3=%RANDOM% * 10000 / 32767"
    rem if password is longer than 14 chars, NET USER /ADD asks stupid question
)
@(
    SET "outlog=%dirPlainOut%\%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%.log"
    IF NOT DEFINED newPasswd SET "PasswdPart1=0000%PasswdPart1%" & SET "PasswdPart2=0000%PasswdPart2%" & SET "PasswdPart3=0000%PasswdPart3%"
)
@(
    IF NOT DEFINED newPasswd (
        SET "newPasswd=%PasswdPart1:~-4%-%PasswdPart2:~-4%-%PasswdPart3:~-4%"
        SET "PasswdPart1=" & SET "PasswdPart2=" & SET "PasswdPart3="
    )

    SET "outPlainFName=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2% %TIME::=% %RANDOM%.txt"
    IF NOT EXIST "%dirPlainOut%" MKDIR "%dirPlainOut%"
    IF NOT "%dirPlainOut:~0,2%"=="\\" %SystemRoot%\System32\cipher.exe /E "%dirPlainOut%"
    SET "gpgencOut="
    SET "gpgServerCopy="
    IF DEFINED dirGPGout (
	IF NOT EXIST "%dirGPGout%" MKDIR "%dirGPGout%"
	SET gpgencOut="%dirGPGout%\%gpgUserID%.txt.gpg"
	IF NOT EXIST "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Administrators\new\%newUsername%" MKDIR "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Administrators\new\%newUsername%"
	SET gpgServerCopy="\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Administrators\new\%newUsername%\%Hostname%.%Domain% %DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2% %TIME::=% %RANDOM%.txt.gpg"
    )
)
@(
    SET "UserAddError="
    rem Create new user
    (
	rem Write password to file
	ECHO %Hostname%\%newUsername%
	NET USER "%newUsername%" "%newPasswd%" /ADD /LOGONPASSWORDCHG:NO /fullName:"%fullName%" || CALL :SetUserAddError
    )>>"%dirPlainOut%\%outPlainFName%" 2>&1
    TYPE "%dirPlainOut%\%outPlainFName%"
    IF DEFINED UserAddError EXIT /B
    IF DEFINED AutohotkeyExe IF EXIST "%dirPlainOut%\%outPlainFName%" (
        rem curl -F "file=@%dirPlainOut%\%outPlainFName%"
        (
            ECHO %newPasswd%
        ) | %AutohotkeyExe% "%~dp0storeTemporaryPassword.ahk" "%newUsername%" >>"%dirPlainOut%\%outPlainFName%"
    )
    IF DEFINED gpgencOut CALL :GpgEncryptPassword
)
:setupgroups
@(
REM END IF [DEFINED flag_p]
    rem Add to admin group. Its name differs depending on Windows language.
    (
	NET LOCALGROUP Administrators "%newUsername%" /Add
	NET LOCALGROUP Администраторы "%newUsername%" /Add
	NET LOCALGROUP Users "%newUsername%" /Delete
	NET LOCALGROUP Пользователи "%newUsername%" /Delete
    ) >NUL 2>&1
    
    IF DEFINED AutoHotkeyExe IF EXIST "D:\Users\*.*" %AutoHotkeyExe% "%~dp0..\MoveUserProfile\SetProfilesDirectory_D_Users.ahk"
    ENDLOCAL
    IF NOT [%GNUPGHOME%]==[] SET GNUPGHOME=%GNUPGHOME%
    IF NOT [%gpgexe%]==[] SET gpgexe=%gpgexe%
    IF NOT [%exe7z%]==[] SET exe7z=%exe7z%
EXIT /B
)
:GpgEncryptPassword
@(
    DEL %gpgencOut% 2>NUL
    REM %gpgexe% -e --batch -a -r "%gpgUserID%" -o %gpgencOut% "%dirPlainOut%\%outPlainFName%" >>"%outlog%" 2>&1
    (
        ECHO %newPasswd%
    )|%gpgexe% -e --batch -a -r "%gpgUserID%" -o %gpgencOut% >>"%outlog%" 2>&1
    IF ERRORLEVEL 1 GOTO :ErrorGPGEncrypting
    DEL "%dirPlainOut%\%outPlainFName%" <NUL
    DEL "%outlog%" <NUL
    RD "%dirPlainOut%" 2>NUL
    START "Copying gpg-encrypted password to Srv1S-B" /MIN %comspec% /C "COPY /Y /B %gpgencOut% %gpgServerCopy%"
    IF DEFINED AutoHotkeyExe START "" %AutoHotkeyExe% "%~dp0submitEncryptedPassword.ahk" "%newUsername%" %gpgencOut%
EXIT /B
)
:ErrorGPGEncrypting
@(
    ECHO Error encrypting password! Leaving it intact.>>"%outlog%"
    TYPE "%outlog%"
    ECHO 
EXIT /B 1
)
:GetValue <targetvarname> <sourcevarname>
@(
    FOR /F "usebackq delims=" %%I IN (`ECHO %%%~2%%`) DO @SET "%~1=%%~I"
EXIT /B
)
:ParseFlags
@(
    SET /A "i=0"
    REM reset flags
    SET "flag_f="
    SET "flag_p="
    SET "flag_r="
    SET "flag_n="
)
:ParseNextFlag
@(
    SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
    SET "curFlag=!flags:~%i%,1!"
)
@(
    ENDLOCAL
    IF "%curFlag%"=="" EXIT /B
    IF NOT DEFINED flag_%curFlag% SET "flag_%curFlag%=1"
    SET /A "i+=1"
    GOTO :ParseNextFlag
)
:AskCreateUser
@SET /P "doit=Создать пользователя %newUsername% (%fullName%)? [0=N=нет, остальное = да]"
@(
    IF "%doit%"=="0" EXIT /B 1
    IF /I "%doit:~0,1%" EQU "n" EXIT /B 1
    IF /I "%doit:~0,1%" EQU "н" EXIT /B 1
EXIT /B 0
)
:SetUserAddError
@(
    rem ERRORLEVEL:
    rem 2	The account already exist
    SET "UserAddError=%ERRORLEVEL%"
EXIT /B
)
