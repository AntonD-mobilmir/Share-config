@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    rem IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
    SET "UseTimeAsVersion=1"
)
(
    SET "UpdateScriptName=Mozilla Thunderbird"
    SET "srcpath=%~dp064-bit\"
    CALL "%baseScripts%\_DistDownload.cmd" "https://download.mozilla.org/?product=thunderbird-latest&os=win64&lang=ru" "Thunderbird Setup *.exe"
    
    SET "addToS_UScripts=0"
    SET "srcpath=%~dp032-bit\"
    CALL "%baseScripts%\_DistDownload.cmd" "https://download.mozilla.org/?product=thunderbird-latest&os=win&lang=ru" "Thunderbird Setup *.exe"
)
