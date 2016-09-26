@REM coding:OEM
REM                                     Automated software update scripts
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru

SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED runDir SET runDir=%srcpath%temp

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

CALL "%~dp0getfilenames.cmd"

CALL "%baseScripts%\_DistDownload.cmd" https://www.adobe.com/products/flashplayer/distribution3.html "%PluginFilename%" -ml 1 -A.exe -HD download.macromedia.com -nd "-e robots=off" --no-check-certificate
CALL "%baseScripts%\_DistDownload.cmd" https://www.adobe.com/products/flashplayer/distribution3.html "%ActiveXFilename%" -ml 1 -A.exe -HD download.macromedia.com -nd "-e robots=off" --no-check-certificate
CALL "%baseScripts%\_DistDownload.cmd" https://www.adobe.com/products/flashplayer/distribution3.html "%ppapiFilename%" -ml 1 -A.exe -HD download.macromedia.com -nd "-e robots=off" --no-check-certificate

CALL :GetLargestNumber LatestPluginFilename "%runDir%\%PluginFilename%"
CALL :GetLargestNumber LatestActiveXFilename "%runDir%\%ActiveXFilename%"
CALL :GetLargestNumber LatestppapiFilename "%runDir%\%ppapiFilename%"

rem second run with latest filenames for linking
CALL "%baseScripts%\_DistDownload.cmd" https://www.adobe.com/products/flashplayer/distribution3.html "%LatestPluginFilename%" -ml 1 -A.exe -HD download.macromedia.com -nd "-e robots=off" --no-check-certificate
CALL "%baseScripts%\_DistDownload.cmd" https://www.adobe.com/products/flashplayer/distribution3.html "%LatestActiveXFilename%" -ml 1 -A.exe -HD download.macromedia.com -nd "-e robots=off" --no-check-certificate
CALL "%baseScripts%\_DistDownload.cmd" https://www.adobe.com/products/flashplayer/distribution3.html "%LatestppapiFilename%" -ml 1 -A.exe -HD download.macromedia.com -nd "-e robots=off" --no-check-certificate

IF NOT DEFINED SUScripts EXIT /B

CALL "%SUScripts%\..\templates\_add_withVer.cmd" "%~dp0%LatestPluginFilename%"
rem CALL "%SUScripts%\..\templates\_add_withVer.cmd" "%~dp0%ActiveXFilename%"

EXIT /B

:GetLargestNumber
    FOR /F "usebackq delims=" %%I IN (`DIR /B /O-N %2`) DO (
	SET "%~1=%%~I"
	GOTO :ExitFor
    )
    :ExitFor
EXIT /B
