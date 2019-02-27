@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" https://www.torproject.org/download/download-easy.html.en *.exe -m -l 2 -HD dist.torproject.org "-A .exe,.asc,.en" -nd --user-agent="Mozilla/5.0 (Windows NT 5.1; rv:0.0)"
)
