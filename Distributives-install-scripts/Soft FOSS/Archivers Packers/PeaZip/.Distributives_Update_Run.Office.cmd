@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

CALL \Scripts\_DistDownload_sf.cmd peazip peazip-*.WINDOWS.exe
