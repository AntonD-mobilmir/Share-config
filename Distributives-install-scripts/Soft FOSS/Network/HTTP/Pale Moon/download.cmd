@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://www.palemoon.org/download-ng.shtml *.exe -m -l 1 -HD mirror.palemoon.org -A .exe -nd
