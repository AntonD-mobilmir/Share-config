@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

rem XCOPY "%s_uscripts%\..\_install\dist\*.cmd" "%ProgramData%\mobilmir.ru" /K /I /H /F /Y || EXIT /B
CALL "%s_uscripts%\..\_install\install_software_update_scripts.cmd"

ECHO.>"%log%"
SCHTASKS /End /TN "mobilmir.ru\SoftwareUpdate"
SCHTASKS /Run /TN "mobilmir.ru\SoftwareUpdate"
EXIT 0
)
