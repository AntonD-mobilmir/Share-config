@REM coding:OEM
SETLOCAL
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET dstpath=%~p0
IF /I "%dstpath:~0,5%" NEQ "Srv0\" GOTO :skipCopying
SET dstpath=d:%dstpath:~4%
MKDIR "%dstpath%"
IF NOT EXIST "%dstpath%" GOTO :skipCopying
XCOPY "%srcpath:~0,-1%" "%dstpath:~0,-1%" /E /C /I /F /G /H /Y
SET srcpath=%dstpath%

:skipCopying

START "" /WAIT /B /D "%srcpath%" "%srcpath%SetupRST.exe" /s

REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v IAStorIcon /f

ENDLOCAL
