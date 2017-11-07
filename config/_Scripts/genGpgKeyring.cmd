@(REM coding:CP866
rem genGpgKeyring.cmd dir-for-pubkey-export email@domain RealName Comment
rem also can be passed as envvars, though command line has priority:
rem     MailUserId = UserName by default
rem     MailDomain = HostName.Domain by default
rem     RealName = %UserName%@%Hostname% by default
rem     Comment = "auto-generated..." by default
rem     gpgexe = found with findgpgexe.cmd
rem     GNUPGHOME = %APPDATA%\gnupg by default
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    IF "%~1"=="" (
	SET "dirExportOpenKey=%TEMP%\gpg-open-key"
    ) ELSE (
	SET "dirExportOpenKey=%~1"
    )
    IF NOT "%~2"=="" FOR /F "delims=@ tokens=1*" %%A IN ("%~2") DO (
	SET "MailUserId=%%~A"
	SET "MailDomain=%%~B"
    )
    IF NOT "%~3"=="" SET "RealName=%~3"
    IF NOT "%~4"=="" SET "Comment=%~4"
    
    rem --no-default-keyring --keyring "%srcpath%keyring.gpg" is not enough: it uses default trustdb!
    IF NOT DEFINED GNUPGHOME SET "GNUPGHOME=%APPDATA%\gnupg"
    FOR /F "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
    FOR /F "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Domain"`) DO SET "Domain=%%~J"
    IF NOT DEFINED Domain FOR /F "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DhcpDomain"`) DO SET "Domain=%%~J"
)
(
    IF NOT "%dirExportOpenKey:~-1%"=="\" SET "dirExportOpenKey=%dirExportOpenKey%\"
    IF EXIST "%GNUPGHOME%" (
	CALL :IfNonEmpty "%GNUPGHOME%\secring.gpg" && EXIT /B 1
	FOR /D %%A IN ("%GNUPGHOME%\private-keys-v*") DO FOR %%B IN ("%%~A\*.key") DO IF NOT "%%~zB"=="0" EXIT /B
    ) ELSE (
	MKDIR "%GNUPGHOME%"
    )

    IF NOT DEFINED gpgexe (
	SET "PATH=%PATH%;%SystemDrive%\SysUtils\libs"
	IF EXIST "%SystemDrive%\SysUtils\gnupg\gpg.exe" ( SET gpgexe="%SystemDrive%\SysUtils\gnupg\gpg.exe" ) ELSE ( CALL "%~dp0findgpgexe.cmd" ) || EXIT /B
    )
    rem IF NOT DEFINED MailUserId CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"

    rem -- for XP only: diskperf.exe -y
    IF DEFINED Domain SET "Hostname=%Hostname%.%Domain%"
)
(
    IF NOT DEFINED MailUserId SET "MailUserId=%UserName%"
    IF NOT DEFINED MailDomain SET "MailDomain=%Hostname%"
    IF NOT DEFINED RealName SET "RealName=%UserName%@%Hostname%"
    IF NOT DEFINED Comment SET "Comment=auto-generated %DATE% %TIME% on %Hostname% to %GNUPGHOME%"
    rem %SystemRoot%\System32\fltmc.exe >nul 2>&1 || IF ERRORLEVEL 1 - not admin
    
    IF NOT EXIST "%dirExportOpenKey%" MKDIR "%dirExportOpenKey%"
    IF NOT EXIST "%GNUPGHOME%" MKDIR "%GNUPGHOME%"
    XCOPY "%~dpn0" "%GNUPGHOME%" /E /I /G /H /K /Y /B

    rem https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html
    rem     ECHO Passphrase:
    rem gpg: -:8: missing argument
    rem  --pinentry-mode loopback
    rem  does not work with gpg2.2+ https://bbs.archlinux.org/viewtopic.php?id=208059
)
(
    ECHO %DATE% %TIME% Staring GPG key generation
    %comspec% /C "ECHO %DATE% %TIME% Staring GPG key generation>"%dirExportOpenKey%%MailUserId%@%MailDomain%.gen.log"" || EXIT /B
    IF NOT EXIST "%dirExportOpenKey%%MailUserId%@%MailDomain%.gen.log" EXIT /B 2
)
@CHCP 65001 >NUL & (
    ECHO %%no-protection
    ECHO Key-Type: RSA
    ECHO Subkey-Type: RSA
    ECHO Expire-Date: 0
    ECHO Name-Real: %RealName%
    ECHO Name-Comment: %Comment%
    ECHO Name-Email: %MailUserId%@%MailDomain%
) | %gpgexe% --homedir "%GNUPGHOME%" --batch --gen-key >> "%dirExportOpenKey%%MailUserId%@%MailDomain%.gen.log" 2>&1 & CHCP 866
(
    IF EXIST "%GNUPGHOME%\secring.gpg" CALL :IfNonEmpty "%GNUPGHOME%\secring.gpg" || DEL "%%~A"
    %gpgexe% --homedir "%GNUPGHOME%" --batch --armor --export "%MailUserId%@%MailDomain%" > "%dirExportOpenKey%%MailUserId%@%MailDomain%.asc"
    CALL :IfNonEmpty "%dirExportOpenKey%%MailUserId%@%MailDomain%.asc" || (
	REM exported key not exist or size=0
	DEL "%dirExportOpenKey%%MailUserId%@%MailDomain%.asc"
	EXIT /B 2
    )
    rem cannot be done in batch mode -- %gpgexe% --homedir "%GNUPGHOME%" --batch --armor --gen-revoke "%MailUserId%@%MailDomain%" > "%dirExportOpenKey%%MailUserId%@%MailDomain%.rev"
    rem %gpgexe% --homedir "%GNUPGHOME%" --batch --import "%GNUPGHOME%\0xE91EA97A.asc"
    rem %gpgexe% --no-default-keyring --keyring "%srcpath%keyring.gpg" --edit-key 0xE91EA97A trust sign tsign save quit
    
    FOR %%A IN ("%~dp0genGpgKeyring\key*.asc") DO %gpgexe% --homedir "%GNUPGHOME%" --batch --import "%%~A"
)
(
    SET nextLineIsFP=
    SET lastLineFP=
    rem --fingerprint is similar but with spaces in fingerprint
    rem without `"..."` quotes, %comspec% says: The filename, directory name, or volume label syntax is incorrect.
    FOR /F "usebackq tokens=1*" %%A IN (`"%gpgexe% --homedir "%GNUPGHOME%" --batch --list-keys"`) DO @(
	IF DEFINED lastLineFP (
	    %comspec% /A /C "ECHO # %%B"
	    %comspec% /A /C "ECHO %%lastLineFP%%:6:"
	    SET lastLineFP=
	) ELSE IF DEFINED nextLineIsFP (
	    rem %comspec% /A /C "ECHO %%A%%B:6:"
	    SET nextLineIsFP=
	    SET "lastLineFP=%%A%%B"
	) ELSE IF "%%~A"=="pub" (
	    SET "nextLineIsFP=1"
	)
    ) >>"%GNUPGHOME%\trust.asc"
    %gpgexe% --homedir "%GNUPGHOME%" --batch --import-ownertrust "%GNUPGHOME%\trust.asc"
    %SystemRoot%\System32\taskkill.exe /F /IM gpg-agent.exe
    ENDLOCAL
    SET "mailUserId=%MailUserId%"
    SET "mailDomain=%MailDomain%"
    SET "dirExportOpenKey=%dirExportOpenKey%"
EXIT /B
) >> "%dirExportOpenKey%%MailUserId%@%MailDomain%.gen.log" 2>&1 
REM EXIT /B is in line above

:IfNonEmpty
(
    IF NOT EXIST %1 EXIT /B 1
    FOR %%A IN (%1) DO IF "%%~zA" NEQ "0" EXIT /B 0
EXIT /B 1
)
