@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET distcleanup=1

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload_sf.cmd" greenshot *.exe
rem http://getgreenshot.org/current/
