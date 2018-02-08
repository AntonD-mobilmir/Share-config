@(REM coding:CP866
ECHO %DATE% %TIME% Running %0

START "Collecting inventory information" /MIN /I %comspec% /C ""\\Srv0\profiles$\Share\Inventory\collector-script\SaveArchiveReport.cmd" >"%TEMP%\SaveArchiveReport.cmd.lock" 2>&1 & DEL "%TEMP%\SaveArchiveReport.cmd.lock""
IF NOT DEFINED AutoHotkeyExe CALL "%~dp0FindAutoHotkeyExe.cmd"

SET "dismLockFile=%TEMP%\WindowsComponentsSetup.lock"
)
(
START "Setting up Windows components" %comspec% /C ""%~dp0Windows Components\WindowsComponentsSetup.cmd">"%dismLockFile%""

CALL "%~dp0DisablePasswordExpiration.cmd"
CALL "%~dp0TimeSync-settings.cmd"
CALL "%~dp0EnableRemoteDesktop.cmd"
CALL "%~dp0Disable Teredo on WinVista or Win7.cmd"
CALL "%~dp0CheckWinVer.cmd" 6 && bcdedit /set nx optout
%comspec% /C "%~dp0registry\reg_commonlysafe.cmd"
CALL "%~dp0CheckWinVer.cmd" 6.2 && CALL "%~dp0share File History for Windows 8.cmd"
CALL "%~dp0dontIncludeRecommendedUpdates.cmd"
%SystemRoot%\Sysmte32\wbem\WMIC.exe recoveros set DebugInfoType = 0

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
