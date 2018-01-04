@(REM coding:CP866
REM Automated software update scripts
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"
)
(
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)

SET "distcleanup=1"
SET "UseTimeAsVersion=1"
CALL "%baseScripts%\_DistDownload.cmd" "https://download.mozilla.org/?product=firefox-esr-latest&os=win&lang=ru" "Firefox Setup *.exe"
)
