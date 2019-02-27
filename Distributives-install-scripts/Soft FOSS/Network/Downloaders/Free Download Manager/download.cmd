@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" http://files.freedownloadmanager.org/fdminst.exe fdminst.exe
    CALL "%baseScripts%\_DistDownload.cmd" http://files.freedownloadmanager.org/lite/fdminst-lite.exe fdminst-lite.exe
)
