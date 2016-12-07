@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload_sf.cmd" mediainfo MediaInfo_*.exe
rem CALL \Scripts\_DistDownload.cmd http://sourceforge.net/projects/mediainfo/files/latest/download MediaInfo_*.exe -m -A.exe -l 1 -nd -H -D downloads.sourceforge.net -e "robots=off" -p --user-agent="Mozilla/5.0 (Windows NT 5.1; rv:0.0)"
