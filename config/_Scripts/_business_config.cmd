@(REM coding:CP866
ECHO %DATE% %TIME% Running %0

START "Collecting inventory information" /MIN /I %comspec% /C ""\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Inventory\collector-script\SaveArchiveReport.cmd" >"%TEMP%\SaveArchiveReport.cmd.lock" 2>&1 & DEL "%TEMP%\SaveArchiveReport.cmd.lock""
IF NOT DEFINED AutoHotkeyExe CALL "%~dp0FindAutoHotkeyExe.cmd"

SET "dismLockFile=%TEMP%\WindowsComponentsSetup.lock"
SET "lockFileBasePath=%TEMP%\%~n0.lock-"
SET /A "lock_file_idx=0"
)
:TryAnotherlockFileBasePath
(
IF EXIST "%lockFileBasePath%*.tmp" DEL "%lockFileBasePath%*.tmp"
IF EXIST "%lockFileBasePath%*.tmp" (
    SET "lockFileBasePath=%TEMP%\%~n0.%RANDOM%.lock-"
    GOTO :TryAnotherlockFileBasePath
)
CALL :ParallelRunCmd "%~dp0Windows Components\WindowsComponentsSetup.cmd"

START "Compacting %SystemRoot%\Logs" /MIN /LOW "%SystemRoot%\System32\COMPACT.exe" /Q /C /I /S:"%SystemRoot%\Logs"
START "Compacting %SystemRoot%\SoftwareDistribution\DataStore" /MIN /LOW %comspec% /C "FOR /R "%SystemRoot%\SoftwareDistribution" %%I IN (.) DO COMPACT /Q /C /I "%%~I""

%SystemRoot%\System32\reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Domain" /d "office0.mobilmir" /f
rem %SystemRoot%\System32\reg.exe ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Domain" /d "office0.mobilmir" /f
%SystemRoot%\System32\wbem\wmic.exe computersystem where name="%COMPUTERNAME%" call joindomainorworkgroup name="OFFICE0"
%SystemRoot%\System32\wbem\WMIC.exe recoveros set DebugInfoType = 0

rem Disable Windows Media Player network sharing service
%SystemRoot%\System32\sc.exe config "WMPNetworkSvc" start= disabled
%SystemRoot%\System32\sc.exe stop "WMPNetworkSvc"

REM Set up security policy and add admin users
CALL :ParallelRunCmd "%~dp0Security\import_policy.cmd"
REM Deny promoted Win10 apps
CALL :ParallelRunCmd "%~dp0Security\AppLocker - Deny promoted apps (Win10).cmd"

CALL "%~dp0CheckWinVer.cmd" 6   && bcdedit /set nx optout
CALL "%~dp0CheckWinVer.cmd" 6.2 && CALL :ParallelRunCmd "%~dp0share File History for Windows 8.cmd"

CALL :ParallelRunCmd "%~dp0DisablePasswordExpiration.cmd"
CALL :ParallelRunCmd "%~dp0TimeSync-settings.cmd"
CALL :ParallelRunCmd "%~dp0EnableRemoteDesktop.cmd"
CALL :ParallelRunCmd "%~dp0Disable Teredo on WinVista or Win7.cmd"
CALL :ParallelRunCmd "%~dp0registry\reg_commonlysafe.cmd"
CALL :ParallelRunCmd "%~dp0dontIncludeRecommendedUpdates.cmd"

CALL :ParallelRunCmd "%~dp0Tasks\All XML.cmd"

CALL :WaitAllLocksRelease
EXIT /B
)

:ParallelRunCmd <%*>
@SET /A "lock_file_idx+=1"
@(
    ECHO Starting in background^(%lock_file_idx%^):
    ECHO %*
    SET "lock%lock_file_idx%=%~1"
    (
        ECHO %DATE% %TIME% %*
    ) >"%lockFileBasePath%%lock_file_idx%.log"
    START "%lock_file_idx%: %~nx1" /B /MIN /BELOWNORMAL %comspec% /C "%* >>"%lockFileBasePath%%lock_file_idx%.tmp" 2>&1"
    EXIT /B
)

:WaitAllLocksRelease
@SET lock
:WaitNextLockRelease
@IF "%lock_file_idx%"=="0" EXIT /B
@(
    :WaitCurrentLockRelease
    FOR /F "usebackq delims=" %%A IN (`ECHO ^%^%lock%lock_file_idx%^%^%`) DO ECHO Checking for %lock_file_idx%: %%A
    MOVE /Y "%lockFileBasePath%%lock_file_idx%.tmp" "%lockFileBasePath%%lock_file_idx%.log" || GOTO :SleepBeforeCheckingAgain
    IF NOT EXIST "%lockFileBasePath%%lock_file_idx%.tmp" (
        ECHO Finished
        SET /A "lock_file_idx-=1"
    )
    GOTO :WaitNextLockRelease
    
    :SleepBeforeCheckingAgain
    PING -n 5 127.0.0.1 >NUL
    GOTO :WaitCurrentLockRelease
)
