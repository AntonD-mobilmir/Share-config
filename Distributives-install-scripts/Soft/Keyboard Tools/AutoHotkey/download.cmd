@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

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
)
(
    IF NOT DEFINED logsDir SET "logsDir=%workdir%"
    IF EXIST "%workdir%new.tmp" RD /S /Q "%workdir%new.tmp"
    MKDIR "%workdir%new.tmp"
    xln.exe "%curDistPath%" "%workdir%new.tmp\%curDistName%"
    START "" /B /WAIT /D "%workdir%new.tmp" wget.exe -N %url%
    
    IF NOT EXIST "%workdir%new.tmp\*.*" (
	rem CURL still ignores server filename. Have no idea what to do with it. So it'll be only used as backup.
	rem -J, --remote-header-name  Use the header-provided filename (H)
	rem -k, --insecure      Allow connections to SSL sites without certs (H)
	rem -L, --location      Follow redirects (H)
	rem -o, --output FILE   Write to FILE instead of stdout
	rem -#, --progress-bar  Display transfer progress as a progress bar
	rem -p, --proxytunnel   Operate through a HTTP proxy tunnel (using CONNECT)
	rem -O, --remote-name   Write output to a file named as the remote file
	rem     --remote-name-all  Use the remote file name for all URLs
	rem -R, --remote-time   Set the remote file's time on the local output
	rem -z, --time-cond TIME   Transfer based on a time condition

	START "" /B /WAIT /D "%workdir%new.tmp" c:\SysUtils\curl.exe -LpR --remote-name-all %timeCond% %url% || CALL :ExitWithError running CURL & EXIT /B
    )
    rem without -o for CURL and -O for wget, filename is unknown
    FOR %%A IN ("%workdir%new.tmp\*.exe") DO (	
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
    CALL :movedst "%workdir%new.tmp\%dlfname%" && MOVE /Y "%srcpath%newver.txt" "%srcpath%ver.txt"
    RD "%workdir%new.tmp"
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
    RD "%workdir%new.tmp"
EXIT /B
)
