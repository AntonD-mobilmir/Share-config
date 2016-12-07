@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1

rem Always points to latest, e.g. 2.x version
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://sourceforge.net/projects/keepass/files/latest/download KeePass-*.zip -N -A.zip
