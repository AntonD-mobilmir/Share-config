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

SET srcpath=%~dp0
CALL "%baseScripts%\_DistDownload.cmd"  http://ahkscript.org/download/1.1/AutoHotkeyHelp.zip AutoHotkeyHelp.zip

SET srcpath=%~dp0ahk-u32\
CALL "%baseScripts%\_DistDownload.cmd"  http://ahkscript.org/download/ahk-u32.zip *.zip

SET srcpath=%~dp0ahk-u64\
CALL "%baseScripts%\_DistDownload.cmd"  http://ahkscript.org/download/ahk-u64.zip *.zip
