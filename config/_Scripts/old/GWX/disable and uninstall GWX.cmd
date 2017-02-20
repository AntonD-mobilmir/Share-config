@(REM coding:OEM
IF NOT DEFINED restarted IF EXIST "%SystemRoot%\SysNative\cmd.exe" SET "restarted=1" & "%SystemRoot%\SysNative\cmd.exe" /C "%~f0" %* & EXIT /B
SETLOCAL

SET "UIDSYSTEM=S-1-5-18;s:y"
SET "UIDAdministrators=S-1-5-32-544;s:y"

IF NOT DEFINED ConfigDir CALL :GetConfigDir || EXIT /B

REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Gwx" /v "DisableGwx" /t REG_DWORD /d 1 /f
rem https://support.microsoft.com/en-us/kb/3080351
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableOSUpgrade" /t REG_DWORD /d 1 /f
REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /v "ReservationsAllowed" /t REG_DWORD /d 0 /f

SET "System32=%SystemDrive%\Windows\System32"
rem IF EXIST "%SystemDrive%\Windows\SysNative\cmd.exe" SET "System32=%SystemDrive%\Windows\SysNative"
)
(
CALL "%ConfigDir%_Scripts\find_exe.cmd" exeSetACL "%SystemDrive%\SysUtils\SetACL.exe"
)
(
%SystemRoot%\System32\taskkill.exe /F /IM GWX.exe
rem "%SystemDrive%\Windows\System32\GWX"
CALL :letmecgange "%System32%\Tasks\Microsoft\Windows\Setup"
MKDIR "%System32%\Tasks.bak\Microsoft\Windows"
MOVE /Y "%System32%\Tasks\Microsoft\Windows\Setup" "%System32%\Tasks.bak\Microsoft\Windows\Setup"
ENDLOCAL
EXIT /B
)
rem wusa.exe /uninstall /kb:3035583 /quiet /norestart

:letmecgange
(
%exeSetACL% -ot file -on %1 -rec cont_obj -actn setowner -ownr "n:%UIDAdministrators%"
%exeSetACL% -ot file -on %1 -actn clear -clr dacl -actn rstchldrn -rst dacl -actn ace -ace "n:%UIDAdministrators%;p:full;i:sc,so;m:set;w:dacl" -actn ace -ace "n:%UIDSYSTEM%;p:full;s:n;i:io,so;m:set;w:dacl"
SHIFT
)
(
IF NOT "%~1"=="" GOTO :letmecgange
EXIT /B
)

:GetConfigDir
(
CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
IF NOT DEFINED DefaultsSource EXIT /B 32010
)
(
CALL :GetDir ConfigDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
