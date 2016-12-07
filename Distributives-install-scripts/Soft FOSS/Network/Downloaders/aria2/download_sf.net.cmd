@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" "http://sourceforge.net/projects/aria2/files/latest/download" aria2-*.zip -m -l 1 -A.zip -nd -H -D downloads.sourceforge.net -e "robots=off" -p --user-agent="Mozilla/5.0 (Windows NT 5.1; rv:0.0)"
