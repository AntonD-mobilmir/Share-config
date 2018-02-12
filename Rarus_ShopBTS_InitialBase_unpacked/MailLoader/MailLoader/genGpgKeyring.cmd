@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

rem https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html
rem     ECHO Passphrase:
rem gpg: -:8: missing argument
rem  --pinentry-mode loopback
rem  does not work with gpg2.2+ https://bbs.archlinux.org/viewtopic.php?id=208059
    
    rem --no-default-keyring --keyring "%srcpath%keyring.gpg" is not enough: it uses default trustdb!
    SET "GNUPGHOME=%~dp0gnupg"
    IF NOT DEFINED gpgexe IF EXIST "%SystemDrive%\SysUtils\gnupg\gpg.exe" ( SET gpgexe="%SystemDrive%\SysUtils\gnupg\gpg.exe" ) ELSE SET gpgexe="%SystemDrive%\SysUtils\gnupg\pub\gpg.exe"
    FOR /F "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"

    IF NOT DEFINED MailUserId CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
)
(
    CALL :IfNonEmpty "%GNUPGHOME%\secring.gpg" && EXIT /B 1
    IF NOT EXIST "%GNUPGHOME%" MKDIR "%GNUPGHOME%"

    IF NOT DEFINED gpgexe (
	SET "PATH=%PATH%;%SystemDrive%\SysUtils\libs"
	IF EXIST "%SystemDrive%\SysUtils\gnupg\gpg.exe" ( SET gpgexe="%SystemDrive%\SysUtils\gnupg\gpg.exe" ) ELSE CALL :FindGPGexe || EXIT /B
    )
    rem IF NOT DEFINED MailUserId SET /P "MailUserId=ID (до @): "
    IF NOT DEFINED MailUserId SET "MailUserId=%USERNAME%_%COMPUTERNAME%"
rem -- for XP only: diskperf.exe -y
)

@CHCP 65001 >NUL & (
    ECHO %%no-protection
    ECHO Key-Type: RSA
    ECHO Subkey-Type: RSA
    ECHO Expire-Date: 0
    ECHO Name-Real: %Hostname%
    ECHO Name-Comment: rarus-exchange-recipient
    ECHO Name-Email: %MailUserId%@k.mobilmir.ru
) | %gpgexe% --homedir "%GNUPGHOME%" --batch --gen-key & CHCP 866
(
    IF EXIST "%GNUPGHOME%\secring.gpg" CALL :IfNonEmpty "%GNUPGHOME%\secring.gpg" || DEL "%%~A" & EXIT /B 2
    FOR %%A IN ("%GNUPGHOME%\key*.asc") DO %gpgexe% --homedir "%GNUPGHOME%" --batch --import "%%~A"
    rem %gpgexe% --homedir "%GNUPGHOME%" --batch --import "%GNUPGHOME%\0xE91EA97A.asc"
    rem %gpgexe% --no-default-keyring --keyring "%srcpath%keyring.gpg" --edit-key 0xE91EA97A trust sign tsign save quit
    %gpgexe% --homedir "%GNUPGHOME%" --batch --import-ownertrust "%GNUPGHOME%\trust.asc"
    %gpgexe% --homedir "%GNUPGHOME%" --batch --list-keys --fingerprint
    EXIT /B
)
:FindGPGexe
(
rem IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
rem CALL :GetDir configDir "%DefaultsSource%"
SET findExeTestExecutionOptions=--homedir "%GNUPGHOME%" --batch --help
SET "pathAppendSubpath=..\libs"
IF NOT DEFINED gpgexe IF EXIST "%SystemDrive%\SysUtils\gnupg\gpg.exe" ( SET gpgexe="%SystemDrive%\SysUtils\gnupg\gpg.exe" ) ELSE CALL "%~dp0..\find_exe.cmd" gpgexe "%SystemDrive%\SysUtils\gnupg\pub\gpg.exe"

rem IF NOT DEFINED exe7z CALL "%configDir%_Scripts\find7zexe.cmd"
rem IF NOT DEFINED SetACLexe CALL "%configDir%_Scripts\find_exe.cmd" SetACLexe SetACL.exe
EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
:IfNonEmpty
(
    IF NOT EXIST %1 EXIT /B 1
    FOR %%A IN (%1) DO IF "%%~zA" NEQ "0" EXIT /B 0
EXIT /B 1
)
