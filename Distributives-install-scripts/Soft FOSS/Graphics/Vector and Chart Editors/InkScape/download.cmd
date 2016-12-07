@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload_sf.cmd" inkscape inkscape-*-win32.7z
