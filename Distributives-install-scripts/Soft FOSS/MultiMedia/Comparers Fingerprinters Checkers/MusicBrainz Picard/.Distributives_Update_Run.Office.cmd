@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" http://picard.musicbrainz.org/downloads/ *.exe -A.exe -ml1 -p --no-check-certificate -nd -e "robots=off" -HDftp.musicbrainz.org
)
