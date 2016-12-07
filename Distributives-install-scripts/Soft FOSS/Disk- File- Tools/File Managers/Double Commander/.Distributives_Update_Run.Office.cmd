@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

CALL \Scripts\_DistDownload_sf.cmd doublecmd *.exe
rem can't DL from sf anything but proposed ("Looking for the latest version?") file
