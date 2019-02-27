@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    SET "distcleanup=1"
    rem CALL "%baseScripts%\_DistDownload.cmd" http://www.palemoon.org/download-ng.shtml *.exe -m -l 1 -HD mirror.palemoon.org -A .exe -nd
    CALL "%baseScripts%\_DistDownload.cmd" "https://www.palemoon.org/download.php?mirror=eu&bits=32&type=installer" palemoon-*.win32.installer.exe -m -l 1 -H -A .exe -nd
    CALL "%baseScripts%\_DistDownload.cmd" "https://www.palemoon.org/download.php?mirror=eu&bits=64&type=installer" palemoon-*.win64.installer.exe -m -l 1 -H -A .exe -nd
)
