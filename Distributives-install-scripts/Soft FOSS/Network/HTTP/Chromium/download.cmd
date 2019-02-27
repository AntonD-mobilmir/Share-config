@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_GetWorkPaths.cmd"
    rem srcpath with baseDistUpdateScripts replaced to baseDistributives
    rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
    rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
    rem logsDir - baseLogsDir with relpath (or nothing)
    IF NOT DEFINED workdir SET "workdir=%srcpath%temp\"
)
(
    IF NOT DEFINED logsDir SET "logsDir=%workdir%"
    IF EXIST "%workdir%chrome-win.zip" MOVE /Y "%workdir%chrome-win.zip" "%workdir%chrome-win.zip.bak"
    IF EXIST "%workdir%chrome-win.zip.bak" SET timeCond=-z "%workdir%chrome-win.zip.bak"
)
(
    CALL %SystemDrive%\SysUtils\curl.exe -LpR %timeCond% -o "%workdir%chrome-win.zip" "https://download-chromium.appspot.com/dl/Win?type=snapshots" %wgetConf% >"%logsDir%snapshots-dl.log" 2>&1
    IF EXIST "%workdir%chrome-win.zip" %SystemDrive%\SysUtils\xln.exe "%workdir%chrome-win.zip" "%srcpath%\chrome-win.zip" >>"%logsDir%snapshots-dl.log" 2>&1
EXIT /B
)


    rem SET "distcleanup=1"
    rem with -N, it says
	rem --2017-02-10 09:43:07--  https://download-chromium.appspot.com/dl/Win?type=snapshots
	rem Connecting to 192.168.127.1:3128... connected.
	rem Proxy request sent, awaiting response... 405 Method Not Allowed
	rem 2017-02-10 09:43:09 ERROR 405: Method Not Allowed.

    rem SET wgetConf=-d -H -e "robots=off" --user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US)" --no-timestamping
    REM --no-timestamping
    REM --no-if-modified-since

