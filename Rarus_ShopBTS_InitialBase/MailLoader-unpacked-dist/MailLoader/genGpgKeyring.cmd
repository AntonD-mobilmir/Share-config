@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    rem --no-default-keyring --keyring "%srcpath%keyring.gpg" is not enough: it uses default trustdb!
    SET "GNUPGHOME=%~dp0gnupg"
    IF NOT DEFINED gpgexe IF EXIST "%SystemDrive%\SysUtils\gnupg\gpg.exe" ( SET gpgexe="%SystemDrive%\SysUtils\gnupg\gpg.exe" ) ELSE SET gpgexe="%SystemDrive%\SysUtils\gnupg\pub\gpg.exe"
    FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"

    IF NOT DEFINED MailUserId CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
)
(
    FOR %%A IN ("%GNUPGHOME%\secring.gpg") DO IF EXIST "%%~A" IF %%~zA GTR 0 (
	ECHO Keyring already exist!
	EXIT /B 1
    )
    IF NOT EXIST "%GNUPGHOME%" MKDIR "%GNUPGHOME%"

rem     IF NOT DEFINED MailUserId SET /P "MailUserId=ID (до @): "
    IF NOT DEFINED MailUserId SET "MailUserId=%USERNAME%_%COMPUTERNAME%"
)
rem -- for XP only: diskperf.exe -y
@CHCP 65001 >NUL & (
    ECHO Key-Type: RSA
    ECHO Subkey-Type: RSA
    ECHO Expire-Date: 0
    ECHO Name-Real: %Hostname%
    ECHO Name-Comment: rarus-exchange-recipient
    ECHO Name-Email: %MailUserId%@k.mobilmir.ru
) | %gpgexe% --homedir "%GNUPGHOME%" --batch --gen-key & CHCP 866
(
    FOR %%A IN ("%GNUPGHOME%\key*.asc") DO %gpgexe% --homedir "%GNUPGHOME%" --batch --import "%%~A"
    rem %gpgexe% --homedir "%GNUPGHOME%" --batch --import "%GNUPGHOME%\0xE91EA97A.asc"
    rem %gpgexe% --no-default-keyring --keyring "%srcpath%keyring.gpg" --edit-key 0xE91EA97A trust sign tsign save quit
    %gpgexe% --homedir "%GNUPGHOME%" --batch --import-ownertrust "%GNUPGHOME%\trust.asc"
    %gpgexe% --homedir "%GNUPGHOME%" --batch --list-keys --fingerprint
)
