@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" http://mattmahoney.net/dc/zpaq.html *.zip -ml1 -nd -A.zip

    rem SET findargs=-name *.exe -and -not -name *64.exe*
    CALL "%baseScripts%\_DistDownload.cmd" http://mattmahoney.net/dc/zpaq.html zpaq.exe -ml1 -nd -A.exe
    CALL "%baseScripts%\_DistDownload.cmd" http://mattmahoney.net/dc/zpaq.html zpaq64.exe -ml1 -nd -A.exe
)
