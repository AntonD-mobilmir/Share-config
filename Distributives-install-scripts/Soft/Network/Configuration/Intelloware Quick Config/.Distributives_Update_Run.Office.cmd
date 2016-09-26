@(REM coding:CP866
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"
)
(
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
)
(
IF NOT DEFINED logsDir SET "logsDir=%workdir%"
SET "UseTimeAsVersion=1"
CALL "%baseScripts%\_DistDownload.cmd" http://intelloware.com/Download/ru-RU/QuickConfig.msi QuickConfig.msi
SET "AddtoSUScripts=0"
CALL "%baseScripts%\_DistDownload.cmd" http://intelloware.com/Download/QuickConfig.zip QuickConfig.zip
)
