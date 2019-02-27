@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    SET "distcleanup=1"
    rem SET findargs=-name *.exe -or -name *.7z
    FOR /F "usebackq delims=" %%I IN (`wget.exe -qO- http://download.wsusoffline.net/StaticDownloadLink-recent.txt`) DO CALL "%baseScripts%\_DistDownload.cmd" %%I *.zip -Nx
)
