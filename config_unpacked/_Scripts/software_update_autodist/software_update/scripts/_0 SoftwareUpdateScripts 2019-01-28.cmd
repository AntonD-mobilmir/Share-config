@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

XCOPY "%SUScripts%\..\_install\dist\*.cmd" "%ProgramData%\mobilmir.ru" /K /I /H /F /Y || EXIT /B

ECHO.>"%log%"
SCHTASKS /End /TN "mobilmir.ru\SoftwareUpdate"
SCHTASKS /Run /TN "mobilmir.ru\SoftwareUpdate"
EXIT 0
)
