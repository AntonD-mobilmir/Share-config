@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
    SET "UseTimeAsVersion=1"
)
(
    SET "UpdateScriptName=Mozilla FireFox"
    SET "srcpath=%~dp064-bit\"
    CALL "%baseScripts%\_DistDownload.cmd" "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=ru" "Firefox Setup *.exe"

    SET "addToS_UScripts=0"
    SET "srcpath=%~dp032-bit\"
    CALL "%baseScripts%\_DistDownload.cmd" "https://download.mozilla.org/?product=firefox-latest&os=win&lang=ru" "Firefox Setup *.exe"
)
