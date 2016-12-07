@Echo Off

VERIFY OTHER 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 ECHO Unable to enable extensions
IF "%srcpath%"=="" SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

wget_the_site.cmd www.fs-driver.org
