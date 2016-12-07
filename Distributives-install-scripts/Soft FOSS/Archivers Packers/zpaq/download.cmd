@REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET srcpath=%~dp0

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

CALL "%baseScripts%\_DistDownload.cmd" http://mattmahoney.net/dc/zpaq.html *.zip -ml1 -nd -A.zip

rem SET findargs=-name *.exe -and -not -name *64.exe*
CALL "%baseScripts%\_DistDownload.cmd" http://mattmahoney.net/dc/zpaq.html zpaq.exe -ml1 -nd -A.exe
CALL "%baseScripts%\_DistDownload.cmd" http://mattmahoney.net/dc/zpaq.html zpaq64.exe -ml1 -nd -A.exe
