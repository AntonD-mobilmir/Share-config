@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
    SET "AddtoS_UScripts=1"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" https://www.stunnel.org/downloads.html -win32-installer.exe -ml1 -nd -A.exe
    CALL "%baseScripts%\_DistDownload.cmd" https://www.stunnel.org/downloads.html -win32-installer.exe.asc -ml1 -nd -A.exe.asc
    CALL "%baseScripts%\_DistDownload.cmd" https://www.stunnel.org/downloads.html -win32-installer.exe.sha256 -ml1 -nd -A.exe.sha256
)
