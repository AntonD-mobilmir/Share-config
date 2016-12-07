@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
rem SET findargs=-name *.exe -or -name *.7z
SET logfname=list.log
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" "http://code.google.com/p/sharex/downloads/list?can=3" *.exe -m -l 2 -e "robots=off" -HD sharex.googlecode.com

rem http://sharex.googlecode.com/files/ShareX-6.6.0.280-setup.exe
