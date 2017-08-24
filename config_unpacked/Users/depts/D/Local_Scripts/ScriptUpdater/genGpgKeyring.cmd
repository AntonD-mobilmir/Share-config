@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    
    SET "outDir=\\Srv0.office0.mobilmir\profiles$\Share\gpg\"
    
    rem --no-default-keyring --keyring "%srcpath%keyring.gpg" is not enough: it uses default trustdb!
    SET "GNUPGHOME=%~dp0gnupg"
    FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"

    IF NOT DEFINED gpgexe IF EXIST "%SystemDrive%\SysUtils\gnupg\pub\gpg.exe" (
	SET "PATH=%PATH%;%SystemDrive%\SysUtils\libs"
	SET gpgexe="%SystemDrive%\SysUtils\gnupg\pub\gpg.exe"
    ) ELSE CALL :FindGPGexe || EXIT /B
    rem IF NOT DEFINED MailUserId CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
)
(
    IF NOT DEFINED MailUserId SET "MailUserId=%Hostname%"
    FOR %%A IN ("%GNUPGHOME%\secring.gpg") DO IF EXIST "%%~A" IF "%%~zA" NEQ "0" (
	ECHO Keyring already exist!
	EXIT /B 1
    )
    IF NOT EXIST "%GNUPGHOME%" MKDIR "%GNUPGHOME%"

    rem -- for XP only: diskperf.exe -y
)
@CHCP 65001 >NUL & (
    ECHO Key-Type: RSA
    ECHO Subkey-Type: RSA
    ECHO Expire-Date: 0
    ECHO Name-Real: %Hostname%
    ECHO Name-Comment: ScriptUpdater
    ECHO Name-Email: %MailUserId%@rarus.robots.mobilmir.ru
) | %gpgexe% --homedir "%GNUPGHOME%" --batch --gen-key >> "%outDir%%MailUserId%@rarus.robots.mobilmir.ru.gen.log" 2>&1 & CHCP 866
(
    FOR %%A IN ("%GNUPGHOME%\secring.gpg") DO IF EXIST "%%~A" IF "%%~zA"=="0" (
	DEL "%%~A"
	EXIT /B 1
    )
    %gpgexe% --homedir "%GNUPGHOME%" --batch --armor --export "%MailUserId%@rarus.robots.mobilmir.ru" > "%outDir%%MailUserId%@rarus.robots.mobilmir.ru.asc"
    rem cannot be done in batch mode -- %gpgexe% --homedir "%GNUPGHOME%" --batch --armor --gen-revoke "%MailUserId%@rarus.robots.mobilmir.ru" > "%outDir%%MailUserId%@rarus.robots.mobilmir.ru.rev"
    FOR %%A IN ("%GNUPGHOME%\key*.asc") DO %gpgexe% --homedir "%GNUPGHOME%" --batch --import "%%~A"
    rem %gpgexe% --homedir "%GNUPGHOME%" --batch --import "%GNUPGHOME%\0xE91EA97A.asc"
    rem %gpgexe% --no-default-keyring --keyring "%srcpath%keyring.gpg" --edit-key 0xE91EA97A trust sign tsign save quit
    %gpgexe% --homedir "%GNUPGHOME%" --batch --import-ownertrust "%GNUPGHOME%\trust.asc"
    %gpgexe% --homedir "%GNUPGHOME%" --batch --list-keys --fingerprint
    EXIT /B
) >> "%outDir%%MailUserId%@rarus.robots.mobilmir.ru.gen.log" 2>&1 
:FindGPGexe
(
rem IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
rem CALL :GetDir ConfigDir "%DefaultsSource%"
SET findExeTestExecutionOptions=--homedir "%GNUPGHOME%" --batch --help
SET "pathAppendSubpath=..\..\libs"
IF NOT DEFINED gpgexe CALL "%~dp0..\find_exe.cmd" gpgexe "%SystemDrive%\SysUtils\gnupg\pub\gpg.exe"
rem IF NOT DEFINED gpgexe CALL "%ConfigDir%_Scripts\find_exe.cmd" gpgexe "%SystemDrive%\SysUtils\gnupg\pub\gpg.exe"
rem IF NOT DEFINED exe7z CALL "%ConfigDir%_Scripts\find7zexe.cmd"
rem IF NOT DEFINED SetACLexe CALL "%ConfigDir%_Scripts\find_exe.cmd" SetACLexe SetACL.exe
EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
