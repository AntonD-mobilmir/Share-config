@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
rem --debug-- SET "ErrorCmd=PAUSE"
IF NOT DEFINED ErrorCmd SET "ErrorCmd=SET ErrorOccured=1"
IF NOT DEFINED gpgexe SET gpgexe="%SystemDrive%\SysUtils\gnupg\pub\gpg.exe"

SET "sidCREATOR_OWNER=S-1-3-0"
SET "ErrorOccured="

IF EXIST "%SystemRoot%\SysNative\cmd.exe" (SET "System32=%SystemRoot%\SysNative") ELSE SET "System32=%SystemRoot%\System32"
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"

IF NOT DEFINED MailUserId CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
FOR %%A IN ("%~dp0dist.7z") DO SET "distTime=%%~tA"
IF NOT DEFINED verFile SET "verFile=D:\1S\Rarus\MailLoader\getmail_dist_ver.txt"
)
CALL :GetDir ConfigDir "%DefaultsSource%"
(
IF NOT EXIST %gpgexe% CALL "\\Srv0.office0.mobilmir\Distributives\Soft FOSS\PreInstalled\manual\SysUtils_GPG.cmd"
IF NOT DEFINED exe7z CALL "%ConfigDir%_Scripts\find7zexe.cmd"
rem IF NOT DEFINED SetACLexe CALL "%ConfigDir%_Scripts\find_exe.cmd" SetACLexe SetACL.exe
IF NOT DEFINED AutohotkeyExe CALL "%ConfigDir%FindAutoHotkeyExe.cmd"

SET "schedUserName=%USERNAME%" & REM https://redbooth.com/a/#!/projects/59756/tasks/31466273
rem IF NOT DEFINED schedUserName CALL "%configDir%_Scripts\AddUsers\AddUser_admin-task-scheduler.cmd" /LeaveExistingPwd
rem IF NOT DEFINED schedUserName CALL :GetCurrentUserName schedUserName
rem IF NOT DEFINED schedUserName SET /P "schedUserName=Имя пользователя для задачи обновления дистрибутивов: "
)
SET "schtaskPassSw=" & IF DEFINED schedUserPwd SET schtaskPassSw=/RP "%schedUserPwd%"
(
rem installer does not allow setting destination - "\\Srv0.office0.mobilmir\Distributives\Soft FOSS\Network\VPN, Tunnels, Gateways and proxies\stunnel\stunnel-5.41-win32-installer.exe" /S
%System32%\schtasks.exe /End /TN mobilmir.ru\stunnel
%System32%\taskkill.exe /F /IM tstunnel.exe
IF EXIST "D:\1S\Rarus\MailLoader\stunnel.bak" RD /S /Q "D:\1S\Rarus\MailLoader\stunnel.bak"
MOVE /Y "D:\1S\Rarus\MailLoader\stunnel" "D:\1S\Rarus\MailLoader\stunnel.bak" && RD /S /Q "D:\1S\Rarus\MailLoader\stunnel.bak"
%exe7z% x -aoa -o"D:\1S\Rarus\MailLoader\stunnel" -x!bin/openssl.exe -x!bin/stunnel.exe -x!*/*.pdb -x!$PLUGINSDIR -x!uninstall.exe "\\Srv0.office0.mobilmir\Distributives\Soft FOSS\Network\VPN, Tunnels, Gateways and proxies\stunnel\stunnel-*-win32-installer.exe" || %ErrorCmd%
rem /grant "*%sidCREATOR_OWNER%:(OI)(CI)F"
%SystemRoot%\System32\icacls.exe "D:\1S\Rarus\MailLoader" /grant "%schedUserName%:(OI)(CI)M" /C /L || %ErrorCmd%
%SystemRoot%\System32\icacls.exe "D:\1S\Rarus\ShopBTS\ExtForms\MailLoader" /grant "%schedUserName%:(OI)(CI)M" /C /L || %ErrorCmd%

%exe7z% x -aoa -oD:\1S\Rarus -- "%~dp0dist.7z" || %ErrorCmd%
DEL "D:\1S\Rarus\MailLoader\POPTrace.txt"

%AutohotkeyExe% "%~dp0fill_config-localhost.template.xml_from_sendemail.cfg.ahk" || IF ERRORLEVEL 2 %ErrorCmd%

CALL :SchTask "D:\1S\Rarus\MailLoader\Tasks\stunnel.xml" /RU "" /NP || %ErrorCmd%
rem CALL :SchTask "D:\1S\Rarus\MailLoader\Tasks\getmail.cmd - Rarus Mail Loader.xml" /RU "%USERNAME%" /NP || %ErrorCmd%
rem /NP не использовать, т.к. файл настроек шифруется от имени пользователя, запустившего getmail.cmd
IF NOT "%RunInteractiveInstalls%"=="0" CALL :SchTask "D:\1S\Rarus\MailLoader\Tasks\getmail.cmd - Rarus Mail Loader.xml" /RU "%schedUserName%" %schtaskPassSw% || %ErrorCmd%

CALL "D:\1S\Rarus\MailLoader\genGpgKeyring.cmd" || IF ERRORLEVEL 2 %ErrorCmd%

(ECHO %distTime%) >"%verFile%"

IF NOT DEFINED ErrorOccured START "" %AutohotkeyExe% "%ConfigDir%_Scripts\Lib\PostGoogleForm.ahk" "https://docs.google.com/a/mobilmir.ru/forms/d/e/1FAIpQLSe0zAvOtFvJ9hizWP6OMiGBKuQQHl90OvgywGP6vgWs9X_Yjg/formResponse" "entry.1309300051=%MailUserId%" "entry.859988755=%Hostname%" "entry.76258453=%distTime%"

EXIT /B
)
:SchTask <xml>
(
rem rem %System32%\SCHTASKS.exe /Delete /TN "mobilmir\%~n1" /F
rem ECHO.|%System32%\SCHTASKS.exe /Create /F /TN "mobilmir.ru\%~n1" /XML %* || EXIT /B
rem %System32%\SCHTASKS.exe /Run /TN "mobilmir.ru\%~n1"
START "Добавлене задачи %~n1 в планировщик" %comspec% /C ""%~dp0SchTasks-Add.cmd" %*"
EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
:GetCurrentUserName <varname>
    IF NOT DEFINED whoamiexe CALL "%configDir%_Scripts\find_exe.cmd" whoamiexe "%SystemDrive%\SysUtils\UnxUtils\whoami.exe"
(
    FOR /F "usebackq delims=\ tokens=2" %%I IN (`%whoamiexe%`) DO SET "%~1=%%~I"
    IF NOT DEFINED %~1 SET "%~1=%USERNAME%"
    EXIT /B
)
