@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET distcleanup=1

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

rem not working since placing on github because very long content-disposition filename (with special characters in it)
rem CALL "%baseScripts%\_DistDownload.cmd" http://ahkscript.org/download/ahk-install.exe AutoHotkey*_Install.exe

CALL "%baseScripts%\_DistDownload.cmd" http://ahkscript.org/download/ahk-install.exe ahk-install.exe -N -O"ahk-install.exe"
