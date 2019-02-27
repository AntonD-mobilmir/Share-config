@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload_github.cmd" https://github.com/tatsuhiro-t/aria2/releases/latest "aria2-" "-win-32bit-build1.zip"
    CALL "%baseScripts%\_DistDownload_github.cmd" https://github.com/tatsuhiro-t/aria2/releases/latest "aria2-" "-win-64bit-build1.zip"
)
