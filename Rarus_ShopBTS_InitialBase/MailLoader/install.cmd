@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF NOT DEFINED ErrorCmd SET "ErrorCmd=PAUSE"

SET "sidCREATOR_OWNER=S-1-3-0"
SET "ErrorOccured="

IF EXIST "%SystemRoot%\SysNative\cmd.exe" (SET "System32=%SystemRoot%\SysNative") ELSE SET "System32=%SystemRoot%\System32"
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"

IF NOT DEFINED MailUserId CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
FOR %%A IN ("%~dp0dist.7z") DO SET "distTime=%%~tA"
)
CALL :GetDir ConfigDir "%DefaultsSource%"
(
IF NOT DEFINED exe7z CALL "%ConfigDir%_Scripts\find7zexe.cmd"
rem IF NOT DEFINED SetACLexe CALL "%ConfigDir%_Scripts\find_exe.cmd" SetACLexe SetACL.exe
IF NOT DEFINED AutohotkeyExe CALL "%ConfigDir%FindAutoHotkeyExe.cmd"
)
(
rem installer does not allow setting destination - "\\Srv0.office0.mobilmir\Distributives\Soft FOSS\Network\VPN, Tunnels, Gateways and proxies\stunnel\stunnel-5.41-win32-installer.exe" /S
%exe7z% x -aoa -o"D:\1S\Rarus\MailLoader\stunnel" -x!bin/openssl.exe -x!bin/stunnel.exe -x!*/*.pdb -x!$PLUGINSDIR -x!uninstall.exe "\\Srv0.office0.mobilmir\Distributives\Soft FOSS\Network\VPN, Tunnels, Gateways and proxies\stunnel\stunnel-*-win32-installer.exe" || SET "ErrorOccured=1"
%SystemRoot%\System32\icacls.exe "D:\1S\Rarus\MailLoader" /grant "*%sidCREATOR_OWNER%:(OI)(CI)F" /grant "%USERNAME%:(OI)(CI)F" /C /L || SET "ErrorOccured=1"

%exe7z% x -aoa -oD:\1S\Rarus -- "%~dp0dist.7z" || SET "ErrorOccured=1"

%AutohotkeyExe% "%~dp0fill_config-localhost.template.xml_from_sendemail.cfg.ahk" || SET "ErrorOccured=1"

CALL :SchTask "D:\1S\Rarus\MailLoader\Tasks\stunnel.xml" /RU "" /NP || SET "ErrorOccured=1"
CALL :SchTask "D:\1S\Rarus\MailLoader\Tasks\getmail.cmd - Rarus Mail Loader.xml" /RU "%USERNAME%" /NP || SET "ErrorOccured=1"

IF DEFINED ErrorOccured (
    %ErrorCmd%
) ELSE START "" %AutohotkeyExe% "%ConfigDir%_Scripts\Lib\PostGoogleForm.ahk" "https://docs.google.com/a/mobilmir.ru/forms/d/e/1FAIpQLSe0zAvOtFvJ9hizWP6OMiGBKuQQHl90OvgywGP6vgWs9X_Yjg/viewform" "entry.1309300051=%MailUserId%" "entry.859988755=%Hostname%" "entry.76258453=%distTime%"

EXIT /B
)
:SchTask <xml>
(
rem %System32%\SCHTASKS.exe /Delete /TN "mobilmir\%~n1" /F
ECHO.|%System32%\SCHTASKS.exe /Create /F /TN "mobilmir.ru\%~n1" /XML %* || EXIT /B
%System32%\SCHTASKS.exe /Run /TN "mobilmir.ru\%~n1"
EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
