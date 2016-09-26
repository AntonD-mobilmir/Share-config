@REM coding:OEM
SETLOCAL
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

CALL "%~dp0download.cmd" %*

IF DEFINED SUScripts FOR %%I IN ("%~dp0AutoHotkey*_Install.exe") DO CALL "%SUScripts%\..\templates\_add_withVer.cmd" "%%~I"
