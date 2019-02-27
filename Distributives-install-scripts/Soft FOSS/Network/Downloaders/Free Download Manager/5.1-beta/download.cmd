@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" http://files2.freedownloadmanager.org/5/5.1-latest/setup_x86.exe
    CALL "%baseScripts%\_DistDownload.cmd" http://files2.freedownloadmanager.org/5/5.1-latest/setup_x64.exe
)
