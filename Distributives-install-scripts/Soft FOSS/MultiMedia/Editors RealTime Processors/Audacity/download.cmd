@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

rem SET findargs=-name *.exe -or -name *.7z
SET logfname=audacity-win-exe.log
CALL "%baseScripts%\_DistDownload.cmd" "http://code.google.com/p/audacity/downloads/list?q=label:Featured" "audacity-win-*.exe" -m -l 2 -e "robots=off" -HD audacity.googlecode.com
SET logfname=audacity-win-zip.log
CALL "%baseScripts%\_DistDownload.cmd" "http://code.google.com/p/audacity/downloads/list?q=label:Featured" "audacity-win-*.zip" -m -l 2 -e "robots=off" -HD audacity.googlecode.com
SET logfname=audacity-manual-zip.log
CALL "%baseScripts%\_DistDownload.cmd" "http://code.google.com/p/audacity/downloads/list?q=label:Featured" "audacity-manual-*.zip" -m -l 2 -e "robots=off" -HD audacity.googlecode.com

rem http://audacity.googlecode.com/files/audacity-win-2.0.2.exe
rem http://audacity.googlecode.com/files/audacity-win-2.0.2.zip
rem http://audacity.googlecode.com/files/audacity-manual-2.0.2.zip
