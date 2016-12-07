@REM coding:OEM
SET srcpath=%~dp0
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
SET distcleanup=1
CALL "%baseScripts%\_DistDownload_sf.cmd" freefilesync FreeFileSync_*.exe
