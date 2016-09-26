@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

CALL "%srcpath%Uninstall.cmd"
CALL "%srcpath%install.cmd"
