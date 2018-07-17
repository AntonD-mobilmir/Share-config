@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "torBrowserDir=%LocalAppData%\Programs\Tor Browser\Browser\TorBrowser"
SET "url=https://autohotkey.com/download/ahk-install.exe"
SET "urlfname=ahk-install.exe"
SET "distfmask=AutoHotkey_*_setup.exe"
IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"

)
(
    FOR /F "usebackq delims=" %%A IN (`DIR /B /O-D "%srcpath%%distfmask%"`) DO (
	SET "curDistPath=%srcpath%%%~A"
	SET "curDistName=%%~nxA"
	SET timeCond=-z "%srcpath%%%~A"
	GOTO :ExitcurDistPathFor
    )
:ExitcurDistPathFor
    CALL "%baseScripts%\_GetWorkPaths.cmd"
    rem srcpath with baseDistUpdateScripts replaced to baseDistributives
    rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
    rem workdir - baseWorkdir with relpath (or %srcpath%temp\ if baseWorkdir isn't defined)
    rem logsDir - baseLogsDir with relpath (or nothing)
    IF NOT DEFINED workdir SET "workdir=%srcpath%temp\"
    
    FOR /F "usebackq delims=: tokens=1*" %%A IN (`TASKLIST /FI "IMAGENAME eq tor.exe" /FO list`) DO IF "%%~A"=="PID" SET torAlreadyRunning=%%~B
    IF NOT DEFINED torAlreadyRunning START "" /B "%torBrowserDir%\Tor\tor.exe" --defaults-torrc "%torBrowserDir%\Data\Tor\torrc-defaults" -f "%torBrowserDir%\Data\Tor\torrc" DataDirectory "%torBrowserDir%\Data\Tor" GeoIPFile "%torBrowserDir%\Data\Tor\geoip" GeoIPv6File "%torBrowserDir%\Data\Tor\geoip6" +__ControlPort 9151 +__SocksPort "127.0.0.1:9150 IPv6Traffic PreferIPv6 KeepAliveIsolateSOCKSAuth"
)
(
    IF NOT EXIST "%workdir%" MKDIR "%workdir%"
    IF NOT DEFINED logsDir SET "logsDir=%workdir%"
    
    PING -n 5 127.0.0.1 >NUL
    DEL "%workdir%\%urlfname%" <NUL >NUL 2>&1
    rem CURL still ignores server filename. Have no idea what to do with it.
    START "" /B /WAIT /D "%workdir%" curl -x socks://127.0.0.1:9150 %timeCond% -o "%workdir%\%urlfname%" -ORL %url% || CALL :ExitWithError running CURL & EXIT /B
    
    IF EXIST "%workdir%\%urlfname%" FOR %%A IN ("%workdir%\%urlfname%") DO (	
	SET "dlfname=%%~nxA"
	FOR /F "usebackq tokens=1*" %%B IN (`c:\SysUtils\lbrisar\getver.exe "%%~A"`) DO (
	    SET "ver=%%~B"
	    
	    IF "%%~nxA"=="%urlfname%" (
		IF NOT DEFINED ver (
		    ECHO Could not determine version of the executable, and it's used to define filename
		) ELSE SET "dstfname=AutoHotkey_%%~B_setup.exe"
	    )
	    IF NOT DEFINED dstfname SET "dstfname=%%~nxA"
	)
	IF DEFINED ver GOTO :ExitGetVerLoop
    )
    IF NOT DEFINED dlfname CALL :ExitWithError Nothing downloaded & EXIT /B 1
)
:ExitGetVerLoop
(
    IF NOT "%ver:~0,2%"=="1." (
	( CALL :ExitWithError Version %ver% downloaded from %url% ^(must be version 1.*^)!
	EXIT /B 1
	) > "%srcpath%warning.txt"
    )
    
    ( ECHO %ver%	%dstfname%
    ) > "%srcpath%newver.txt"
    rem SET "dstfname=AutoHotkey_%ver%_setup.exe"
    CALL :movedst "%workdir%%dlfname%" && MOVE /Y "%srcpath%newver.txt" "%srcpath%ver.txt"
    RD "%workdir%"
    IF NOT DEFINED torAlreadyRunning TASKKILL /F /IM tor.exe
EXIT /B 0
)
:movedst
(
    SET cleanup_action=CALL "%baseScripts%\mvold.cmd"
    CALL "%baseScripts%\DistCleanup.cmd" "%srcpath%%distfmask%" "%srcpath%%dstfname%"
rem     %SystemDrive%\SysUtils\xln.exe %1 "%srcpath%%dstfname%"||
    MOVE /Y %1 "%srcpath%%dstfname%"
EXIT /B
)
:ExitWithError
(
    ECHO [!!!] %DATE% %TIME% Error: %*
    RD "%workdir%"
    IF NOT DEFINED torAlreadyRunning TASKKILL /F /IM tor.exe
EXIT /B
)
