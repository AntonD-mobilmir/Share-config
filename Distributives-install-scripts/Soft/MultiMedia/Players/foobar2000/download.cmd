@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET "distcleanup=1"
rem SET findpath=www.foobar2000.org\files
IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"
)
(
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
SET "findargs=-name *.exe -and -not -name *beta*"
)
CALL "%baseScripts%\_DistDownload.cmd" http://www.foobar2000.org/download *.exe -ml2 -nd -A.exe
