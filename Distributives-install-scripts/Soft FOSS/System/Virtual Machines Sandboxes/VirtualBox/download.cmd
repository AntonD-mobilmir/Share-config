@REM coding:OEM
SET srcpath=%~dp0
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" https://www.virtualbox.org/wiki/Downloads *.exe -ml1 -A.exe --no-check-certificate -nd -HD download.virtualbox.org
