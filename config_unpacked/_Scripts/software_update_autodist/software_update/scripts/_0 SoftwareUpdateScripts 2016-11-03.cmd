@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

MKDIR "%ProgramData%\mobilmir.ru"
IF EXIST "%SystemDrive%\Local_Scripts" (
    MOVE /Y "%SystemDrive%\Local_Scripts\*" "%ProgramData%\mobilmir.ru\"
    FOR /D %%I IN ("%SystemDrive%\Local_Scripts\*") DO MOVE /Y "%%~I" "%ProgramData%\mobilmir.ru\%%~nxI"
    MOVE /Y "%SystemDrive%\Local_Scripts" "%ProgramData%\mobilmir.ru"
    "%SystemDrive%\SysUtils\xln.exe" -n "%ProgramData%\mobilmir.ru" "%SystemDrive%\Local_Scripts"
)

XCOPY "%SUScripts%\..\_install\dist\*.cmd" "%ProgramData%\mobilmir.ru" /K /I /H /F /Y || EXIT /B

ECHO.>"%log%"
SCHTASKS /End /TN "mobilmir.ru\SoftwareUpdate"
SCHTASKS /End /TN SoftwareUpdate
SCHTASKS /Run /TN "mobilmir.ru\SoftwareUpdate"
SCHTASKS /Run /TN SoftwareUpdate
EXIT 0
)
