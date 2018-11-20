@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
rem CALL "%baseScripts%\_DistDownload.cmd" http://www.palemoon.org/download-ng.shtml *.exe -m -l 1 -HD mirror.palemoon.org -A .exe -nd
CALL "%baseScripts%\_DistDownload.cmd" "https://www.palemoon.org/download.php?mirror=eu&bits=32&type=installer" palemoon-*.win32.installer.exe -m -l 1 -H -A .exe -nd
CALL "%baseScripts%\_DistDownload.cmd" "https://www.palemoon.org/download.php?mirror=eu&bits=64&type=installer" palemoon-*.win64.installer.exe -m -l 1 -H -A .exe -nd
