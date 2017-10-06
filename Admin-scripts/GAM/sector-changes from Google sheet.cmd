@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

CALL "%~dp0_get Google sheet URLs.cmd"
SET "DropboxGAMDir=%USERPROFILE%\Dropbox\it.mobilmir.ru Team Folder\GAM"
)
:tryothername
SET "csvName=sector-changes-%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%%suffix%.csv"
(
    IF EXIST "%~dp0%csvName%" (
	SET "suffix=T%TIME::=%.%RANDOM%"
	GOTO :tryothername
    )
    (
    C:\SysUtils\wget.exe -O"%~dp0%csvName%" "%csvURL%"
    IF EXIST "%DropboxGAMDir%" IF NOT EXIST "%DropboxGAMDir%\%csvName%" XCOPY "%~dp0%csvName%" "%DropboxGAMDir%\" /I /F /G /H /K /Y /B
    CALL "%~dp0sector-changes.cmd" "%~dp0%csvName%"
    IF ERRORLEVEL 1 CALL :EchoError
    START "" "%editURL%"
    ECHO Скопируйте A:B в F:G ^(только значения^)
    PAUSE
    )
    EXIT /B
)

:EchoError
(
ECHO Ошибка %ERRORLEVEL%
EXIT /B
)
