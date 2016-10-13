@(REM coding:CP866
ECHO %DATE% %TIME% Running %0

START "Collecting inventory information" /I %comspec% /C "\\Srv0\profiles$\Share\Inventory\collector-script\SaveArchiveReport.cmd"
IF NOT DEFINED AutoHotkeyExe CALL "%~dp0FindAutoHotkeyExe.cmd"

rem Disable IE 11 upgrade due to Megafon SBMS incompatibility
rem REG ADD "HKLM\SOFTWARE\Microsoft\Internet Explorer\Setup\11.0" /v DoNotAllowIE11 /t REG_DWORD /d 1 /f
CALL "%~dp0DoNotAllowIE11 Install via Windows Update.cmd"
SET "dismLockFile=%TEMP%\WindowsComponentsSetup.lock"
ECHO %DATE% %TIME% Run UserBenchmark
%AutoHotkeyExe% "\\192.168.1.80\profiles$\Share\config\_Scripts\GUI\Run_UserBenchMark.ahk"
)
(
START "Setting up Windows components" %comspec% /C ""%~dp0Windows Components\WindowsComponentsSetup.cmd">"%dismLockFile%""

CALL "%~dp0DisablePasswordExpiration.cmd"
CALL "%~dp0TimeSync-settings.cmd"
CALL "%~dp0EnableRemoteDesktop.cmd"
CALL "%~dp0CheckWinVer.cmd" 6 && bcdedit /set nx optout
%comspec% /C "%~dp0registry\reg_commonlysafe.cmd"
CALL "%~dp0CheckWinVer.cmd" 6.2 && CALL "%~dp0share File History for Windows 8.cmd"
CALL "%~dp0dontIncludeRecommendedUpdates.cmd"

REM Set up security policy and add admin users
%comspec% /C "%~dp0Security\import_policy.cmd"
REM Deny promoted Win10 apps
%comspec% /C "%~dp0Security\Security\AppLocker - Deny promoted apps (Win10).cmd"

ECHO "Compacting %SystemRoot%\Logs"
%SystemRoot%\System32\COMPACT.exe /Q /C /I /S:"%SystemRoot%\Logs"
ECHO "Compacting %SystemRoot%\SoftwareDistribution\DataStore"
FOR /R "%SystemRoot%\SoftwareDistribution" %%I IN (.) DO COMPACT /Q /C /I "%%~I"

rem Disable Windows Media Player network sharing service
%SystemRoot%\System32\sc.exe config "WMPNetworkSvc" start= disabled
%SystemRoot%\System32\sc.exe stop "WMPNetworkSvc"

CALL "%~dp0Tasks\All XML.cmd"
)

rem Wait until windows components set up
:WaitWindowsComponentsSetup
IF DEFINED dismLockFile (
    DEL "%dismLockFile%"
    IF EXIST "%dismLockFile%" (
	PING 127.0.0.1 -n 10 >NUL
	GOTO :WaitWindowsComponentsSetup
    )
)
