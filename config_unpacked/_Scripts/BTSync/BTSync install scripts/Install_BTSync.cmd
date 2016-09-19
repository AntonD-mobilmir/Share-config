@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "lProgramFiles=%ProgramFiles%"
IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"

IF EXIST W:\Distributives\config ECHO Move or link W:\Distributives to D:\Distributives! & PAUSE

SET "UIDEveryone=S-1-1-0;s:y"
SET "UIDAuthenticatedUsers=S-1-5-11;s:y"
SET "UIDUsers=S-1-5-32-545;s:y"
SET "UIDSYSTEM=S-1-5-18;s:y"
SET "UIDCreatorOwner=S-1-3-0;s:y"
SET "UIDAdministrators=S-1-5-32-544;s:y"

SET "distver=1.3.109.0"
SET "SchedulerTypeXP=0"
SET "LocalDist=D:\Distributives"
SET "BTSyncBaseDir=%USERPROFILE%\BTSync"
)
(
    IF NOT DEFINED SetACLexe CALL "%LocalDist%\config\_Scripts\find_exe.cmd" SetACLexe SetACL.exe

    SET "BTSyncDistRoot=%BTSyncBaseDir%\Distributives"
    SET "LocalDistloc=%LocalDist%\Soft com freeware\Network\Peer-to-Peer\BitTorrent Sync\BTSync-1.3.109.exe"
    CALL "%LocalDist%\config\_Scripts\CheckWinVer.cmd" 6 || SET "SchedulerTypeXP=1"
    "%SystemRoot%\System32\schtasks.exe" /End /TN BTSync
    "%SystemRoot%\System32\schtasks.exe" /End /TN mobilmir\BTSync
    "%SystemRoot%\System32\schtasks.exe" /End /TN mobilmir.ru\BTSync
    ping 127.0.0.1 -n 5 >NUL
    TASKKILL /F /IM btsync.exe
    
    FOR /R %LocalDist% %%I IN (".sync*") DO (
	IF "%%~nxI"==".sync" DEL "%%~I"
	IF "%%~nxI"==".sync.includes" DEL "%%~I"
	IF "%%~nxI"==".sync.excludes" DEL "%%~I"
    )
    
    CALL "%~dp0copyAndInstall.cmd" "%LocalDist%\Soft\PreInstalled\auto\Common_Scripts.cmd"
    CALL "%~dp0copyAndInstall.cmd" "%LocalDist%\Soft\PreInstalled\auto\AutoHotkey_Lib.cmd"
    CALL "%~dp0copyAndInstall.cmd" "%LocalDist%\Soft\PreInstalled\auto\AutoHotkey.cmd"

    SET "distloc=%LocalDistloc%"
)
(
    IF NOT EXIST "%distloc%" SET "distloc=\\Srv0.office0.mobilmir\Distributives\Soft com freeware\Network\Peer-to-Peer\BitTorrent Sync\BTSync-1.3.109.exe"

    rem Selecting correct scheduler task for the system
    SET "localinstexe=C:\Program Files\BitTorrent Sync\BTSync.exe"
    SET "BTSyncxml=BTSync.xml"
)
    IF EXIST "C:\Program Files (x86)\BitTorrent Sync\BTSync.exe" (
	SET "localinstexe=C:\Program Files (x86)\BitTorrent Sync\BTSync.exe"
	IF NOT EXIST "c:\Program Files\AutoHotkey\AutoHotkey.exe" (
	    SET "BTSyncxml=BTSync_x86 via AutoHotkey_x86.xml"
	) ELSE (
	    SET "BTSyncxml=BTSync_x86 via AutoHotkey.xml"
	)
    )
(
    MKDIR "%BTSyncDistRoot%"
    MKDIR "%BTSyncBaseDir%\software_update"
    
    IF DEFINED SetACLexe FOR %%A IN ("%BTSyncBaseDir%" "%LocalDist%") DO (
	%SystemRoot%\System32\takeown.exe /F "%USERPROFILE%\BTSync" /A /R /D Y
	%SetACLexe% -on %%A -ot file -rec cont_obj -actn setowner -ownr "n:%UIDAdministrators%" -actn rstchldrn -rst dacl
	%SetACLexe% -on %%A -ot file -actn ace -ace "n:%UIDEveryone%;p:full;m:revoke" -actn ace -ace "n:%UIDEveryone%;p:read_ex"
    )

    XCOPY "%~dp0Distributives" "%BTSyncDistRoot%" /I /H /R /K /Y
    
    CALL :CheckMoveLink config
    CALL :CheckMoveLink Soft
    CALL :CheckMoveLink "Drivers\Canon\Laser MF"
    CALL :CheckMoveLink "Drivers\Metrologic"
    CALL :CheckMoveLink "Drivers\Prolific"
    CALL :CheckMoveLink "Drivers\FTDI"
    
    FOR /F "usebackq tokens=1" %%I IN (`c:\SysUtils\lbrisar\getver.exe "%localinstexe%"`) DO SET "instver=%%~I"
)
:scheduleBTSyncTask
SET "repeatSch=0"
IF "%SchedulerTypeXP%"=="1" (
    "%SystemRoot%\System32\schtasks.exe" /end /tn btsync
    xcopy "%~dp0BTSync.job" "%WinDir%\Tasks\*" /H /R /K /Y
    "%SystemRoot%\System32\schtasks.exe" /Change /TN BTSync /RU "%USERNAME%"
) ELSE (
    "%SystemRoot%\System32\schtasks.exe" /end /tn mobilmir\btsync
    "%SystemRoot%\System32\schtasks.exe" /end /tn mobilmir.ru\btsync
    "%SystemRoot%\System32\schtasks.exe" /Delete /TN mobilmir\BTSync /F
    START "schtasks.exe mobilmir.ru\BTSync" /WAIT "%SystemRoot%\System32\schtasks.exe" /Create /TN mobilmir.ru\BTSync /XML "%~dp0%BTSyncxml%" /NP /F
rem     /RU "%USERNAME%" 
)
IF ERRORLEVEL 1 SET /P "repeatSch=Try again? [1=yes] "
IF "%repeatSch%"=="1" GOTO :scheduleBTSyncTask

IF "%distver%" NEQ "%instver%" (
    ping 127.0.0.1 -n 5 >NUL
    TASKKILL /F /IM btsync.exe
    CALL "%~dp0copyAndInstall.cmd" "%LocalDistloc%"
    START "" "%~dp0RemoveStartMenuShortcut.ahk"
)

ECHO Finished. Press Any key to run BTSync
PAUSE >NUL
START "" "%lProgramFiles%\BitTorrent Sync\BTSync.exe"
EXIT /B

:CheckMoveLink
    IF NOT EXIST "%BTSyncDistRoot%\%~1" (
	IF EXIST "%LocalDist%\%~1" (
	    MKDIR "%BTSyncDistRoot%\%~1"
	    RD "%BTSyncDistRoot%\%~1"
	    MOVE /Y "%LocalDist%\%~1" "%BTSyncDistRoot%\%~1"
	) ELSE (
	    MKDIR "%BTSyncDistRoot%\%~1"
	)
	"%SystemDrive%\SysUtils\xln.exe" -n "%BTSyncDistRoot%\%~1" "%LocalDist%\%~1"||PAUSE
    )
EXIT /B
