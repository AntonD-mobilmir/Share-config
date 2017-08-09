@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"
    SET "distcleanup=1"
    rem with -N, it says
	rem --2017-02-10 09:43:07--  https://download-chromium.appspot.com/dl/Win?type=snapshots
	rem Connecting to 192.168.127.1:3128... connected.
	rem Proxy request sent, awaiting response... 405 Method Not Allowed
	rem 2017-02-10 09:43:09 ERROR 405: Method Not Allowed.

    SET wgetConf=-d -H -e "robots=off" --user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US)" --no-timestamping
    REM --no-timestamping
    REM --no-if-modified-since
)
(
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED workdir SET "workdir=%srcpath%temp"
)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"
(
rem Latest (may be broken): https://download-chromium.appspot.com/
rem CALL "%baseScripts%\_DistDownload.cmd" http://download-chromium.appspot.com//dl/Win *.zip -N -H -e "robots=off" --user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US)" --no-check-certificate >"%logsDir%dl-lock.flag"

rem Last Known Good: https://download-chromium.appspot.com/?platform=Win&type=continuous
rem SET "dstrename=chrome-win32-continuous.zip"
rem CALL "%baseScripts%\_DistDownload.cmd" "https://download-chromium.appspot.com/dl/Win?type=continuous" "Win@type=continuous" %wgetConf% >"%logsDir%continuous-dl.log" 2>&1
rem SET "dstrename=chrome-win32.zip"
rem CALL "%baseScripts%\_DistDownload.cmd" "https://download-chromium.appspot.com/dl/Win?type=snapshots" "Win@type=snapshots" %wgetConf% >"%logsDir%snapshots-dl.log" 2>&1

DEL "%workdir%\chrome-win32.zip"
CALL "%baseScripts%\_DistDownload.cmd" "https://download-chromium.appspot.com/dl/Win?type=snapshots" "chrome-win32.zip" %wgetConf% >"%logsDir%snapshots-dl.log" 2>&1
EXIT /B
)
