@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    SET "AddtoS_UScripts=0"
    CALL "%baseScripts%\_DistDownload.cmd" http://www.parmavex.co.uk/WinAudit.zip WinAudit.zip -N
)
