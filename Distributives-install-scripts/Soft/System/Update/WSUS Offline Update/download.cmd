@(REM coding:CP866
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    SET "distcleanup=1"
    rem SET findargs=-name *.exe -or -name *.7z
    IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"
)
(
    FOR /F "usebackq delims=" %%I IN (`wget.exe -qO- http://download.wsusoffline.net/StaticDownloadLink-recent.txt`) DO CALL "%baseScripts%\_DistDownload.cmd" %%I *.zip -Nx
)
