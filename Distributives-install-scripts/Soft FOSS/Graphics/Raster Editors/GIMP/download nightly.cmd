@REM coding:OEM
SET srcpath=%~dp0
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://nightly.darkrefraction.com/gimp/ gimp-dev-*.exe -ml1 -A.exe
