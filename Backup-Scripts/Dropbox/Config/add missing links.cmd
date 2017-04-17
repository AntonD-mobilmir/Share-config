@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

FOR /D %%I IN ("%~dp0@%COMPUTERNAME%\*") DO @IF EXIST "%%~I\_link.cmd" CALL "%%~I\_link.cmd"
