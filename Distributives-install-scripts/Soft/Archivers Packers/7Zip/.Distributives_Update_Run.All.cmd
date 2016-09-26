@(REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
SET "srcpath=%~dp0"

SET "distcleanup=1"
SET "AddtoSUScripts=1"

IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"
)
(
CALL "%baseScripts%\_DistDownload.cmd" http://www.7-zip.org/ *.exe -ml1 -nd -A.exe
CALL "%baseScripts%\_DistDownload.cmd" http://www.7-zip.org/ *-x64.exe -ml1 -nd -A.exe
)
