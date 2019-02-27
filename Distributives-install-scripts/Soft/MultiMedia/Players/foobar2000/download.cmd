@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
    rem SET findpath=www.foobar2000.org\files
    SET "findargs=-name *.exe -and -not -name *beta*"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" http://www.foobar2000.org/download *.exe -ml2 -nd -A.exe
)
