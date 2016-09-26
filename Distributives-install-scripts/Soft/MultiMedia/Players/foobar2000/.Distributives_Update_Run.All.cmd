@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET AddtoSUScripts=1
CALL "%~dp0download.cmd" %*
