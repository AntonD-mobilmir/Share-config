@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://www.jumaros.de/rsoft/download/gpgsh.php *.zip
