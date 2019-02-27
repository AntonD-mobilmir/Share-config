@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
    SET "UseTimeAsVersion=1"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" "https://download.mozilla.org/?product=firefox-esr-latest&os=win&lang=ru" "Firefox Setup *.exe"
)
