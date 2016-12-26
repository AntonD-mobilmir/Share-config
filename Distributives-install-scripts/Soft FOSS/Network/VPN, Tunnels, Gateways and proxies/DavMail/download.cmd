@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

CALL \Scripts\_DistDownload_sf.cmd davmail *.exe
