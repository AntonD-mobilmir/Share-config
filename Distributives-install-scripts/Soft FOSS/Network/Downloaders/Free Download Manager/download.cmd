@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://files.freedownloadmanager.org/fdminst.exe fdminst.exe
CALL "%baseScripts%\_DistDownload.cmd" http://files.freedownloadmanager.org/lite/fdminst-lite.exe fdminst-lite.exe
