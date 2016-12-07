@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
rem CALL "%baseScripts%\_DistDownload.cmd" https://musicbrainz.org/doc/MusicBrainz_Picard *.exe -A.exe -ml1 --no-check-certificate -nd -e "robots=off" -HDftp.musicbrainz.org
CALL "%baseScripts%\_DistDownload.cmd" http://picard.musicbrainz.org/downloads/ *.exe -A.exe -ml1 -p --no-check-certificate -nd -e "robots=off" -HDftp.musicbrainz.org
