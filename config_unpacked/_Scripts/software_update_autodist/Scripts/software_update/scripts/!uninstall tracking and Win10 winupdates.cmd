@REM coding:OEM
(
SETLOCAL ENABLEEXTENSIONS
IF NOT "%RunInteractiveInstalls%"=="0" GOTO :skipVerCheck
IF NOT DEFINED ConfigDir CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" && CALL :getConfigDir || EXIT /B
)
CALL "%ConfigDir%_Scripts\CheckWinVer.cmd" 6.1 || EXIT /B
:skipVerCheck
(
REM prior to Win7, wusa cannot uninstall updates; but also MS didnt release these updates for that systems
SET "System32=%SystemRoot%\System32"
IF EXIST "%SystemRoot%\SysNative\*.*" SET "System32=%SystemRoot%\SysNative"

rem https://support.microsoft.com/en-us/kb/3080351
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade" /d 1 /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /v "ReservationsAllowed" /d 0 /f
)
(
rem Список с объяснениями: https://docs.google.com/spreadsheets/d/1OZfazpVPCoHJYGo4s7oFeuRXmzcZeYktbMdZTUB5SDU
rem refs:
rem http://www.wilderssecurity.com/threads/list-of-windows-7-telemetry-updates-to-avoid.379151/
rem http://www.infoworld.com/article/3029642/microsoft-windows/kb-3135449-and-3135445-could-be-useful-but-ignore-the-rest-of-microsofts-batch.html
rem http://www.ghacks.net/2016/05/05/kb3150513-is-another-windows-10-update-patch/

"%System32%\wusa.exe" /uninstall /kb:3173040 /quiet /norestart & rem Windows 8.1 and Windows 7 SP1 end of free upgrade offer notification
rem "%System32%\wusa.exe" /uninstall /kb:3150513 /quiet /norestart & rem May 2016 Compatibility Update for Windows
rem 3135445 not ??? uninstalling this one because it only updates (??? advertising): Windows Update Client for Windows 7 and Windows Server 2008 R2: February 2016
"%System32%\wusa.exe" /uninstall /kb:3123862 /quiet /norestart & rem Updated capabilities to upgrade Windows 8.1 and Windows 7
"%System32%\wusa.exe" /uninstall /kb:3080149 /quiet /norestart & rem Update for customer experience and diagnostic telemetry
"%System32%\wusa.exe" /uninstall /kb:3075249 /quiet /norestart & rem Update that adds telemetry points to consent.exe in Windows 8.1 and Windows 7
"%System32%\wusa.exe" /uninstall /kb:3068708 /quiet /norestart & rem (replaces KB3022345) Update for customer experience and diagnostic telemetry
"%System32%\wusa.exe" /uninstall /kb:3035583 /quiet /norestart & rem Update installs get windows 10 app in Windows 8.1 and Windows 7 SP1
"%System32%\wusa.exe" /uninstall /kb:3022345 /quiet /norestart & rem Update for customer experience and diagnostic telemetry
rem not uninstalling this one because it only updates CEIP components, which are already present anyway  - "%System32%\wusa.exe" /uninstall /kb:3021917 /quiet /norestart & rem Update to Windows 7 SP1 for performance improvements
"%System32%\wusa.exe" /uninstall /kb:2990214 /quiet /norestart & rem Update that enables you to upgrade from Windows 7 to a later version of Windows
rem "%System32%\wusa.exe" /uninstall /kb:2977759 /quiet /norestart & rem Compatibility update for Windows 7 RTM - runs tests when installed; if uninstalled, will run tests again on next autoinstall
rem "%System32%\wusa.exe" /uninstall /kb:2976978 /quiet /norestart & rem Compatibility update for Windows 8.1 and Windows 8; if uninstalled, will run tests again on next autoinstall
"%System32%\wusa.exe" /uninstall /kb:2952664 /quiet /norestart & rem Compatibility update for upgrading Windows 7
EXIT /B
)
:getConfigDir
(
CALL :GetDir configDir "%DefaultsSource%"
IF NOT DEFINED configDir EXIT /B 1
EXIT /B
)
:GetDir <outvar> <path>
(
SET "%~1=%~dp2"
EXIT /B
)
