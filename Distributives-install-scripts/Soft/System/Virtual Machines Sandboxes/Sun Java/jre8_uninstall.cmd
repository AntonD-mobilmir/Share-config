@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "uninstallNext=1"
IF "%~1"=="/LeaveLast" SET "uninstallNext="
)
FOR /F "usebackq eol=# tokens=1,2*" %%A IN ("%~dp0jre8_uids.txt") DO @(
    IF DEFINED uninstallNext (
	ECHO Uninstalling %%B
	%SystemRoot%\System32\msiexec.exe /x {%%A} /qn /norestart
    ) ELSE (
	ECHO Skipping %%B
	SET "uninstallNext=1"
    )
)
