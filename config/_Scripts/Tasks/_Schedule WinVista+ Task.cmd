@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF EXIST "%SystemRoot%\SysNative\*.*" (SET "System32=%SystemRoot%\SysNative") ELSE SET "System32=%SystemRoot%\System32"

SET "ArchiveName=%~1"
SET "TaskName=%~2"
SET "XML=%~3"
SET /A "ErrorCount=0"
SET "ErrorList="
SET "TempXMLOut=%TEMP%\%~n0.%RANDOM%"
)
:CollectArgs
(
SET "AddArgs=%AddArgs% %4"
IF NOT "%~5"=="" (
    SHIFT
    GOTO :CollectArgs
)
)
(
MKDIR "%TempXMLOut%"
IF "%XML%"=="" SET "XML=%TaskName%.xml"
IF NOT "%ArchiveName%"=="" (
    IF NOT DEFINED exe7z CALL "%srcpath%..\find7zexe.cmd" || EXIT /B
    IF NOT EXIST "%ArchiveName%" IF EXIST "%srcpath%%ArchiveName%" SET "ArchiveName=%srcpath%%ArchiveName%"
)
)
(
IF NOT "%ArchiveName%"=="" (
    %exe7z% x -o"%TempXMLOut%" -- "%ArchiveName%" "%XML%"
)
IF "%TaskName%"=="*" (
    FOR %%I IN ("%TempXMLOut%\%XML%") DO CALL :ScheduleSingleTask "%%~nI" "%%~I"
) ELSE (
    CALL :ScheduleSingleTask "%TaskName%" "%TempXMLOut%\%XML%"
)
RD /S /Q "%TempXMLOut%"
EXIT /B
)
:ScheduleSingleTask <TaskName> <XML>
(
    rem %System32%\SCHTASKS.exe /Delete /TN "mobilmir\%~1" /F
    ECHO.|%System32%\SCHTASKS.exe /Create /TN "mobilmir.ru\%~1" /XML %2 %AddArgs% /F
)
(
    IF ERRORLEVEL 1 (
	SET /A "ErrorCount+=1"
	SET "ErrorList=%ErrorList%%~1: %ERRORLEVEL%; "
    )
EXIT /B
)
