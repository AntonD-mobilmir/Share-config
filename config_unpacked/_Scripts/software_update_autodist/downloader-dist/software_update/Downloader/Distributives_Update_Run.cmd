@(REM coding:CP866
ECHO OFF
REM Automated software update scripts
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SET "DistUpdRunDir=%CD%\"
SET "PATH=%PATH%;%~dp0"

ECHO.
ECHO %DATE% %TIME% Starting distributives download
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
)
CALL "%ProgramData%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd"
(
SET "s_uscripts=%~dp0..\client_exec"
REM depts SET "s_uscripts=%DistUpdRunDir%software_update\scripts"
rem old office SET "s_uscripts=x:\Shares\profiles$\Share\software_update\scripts"

SET "baseScripts=%~dp0"
)
(
SET "baseScripts=%baseScripts:~,-1%"
SET "baseDistUpdateScripts=%~dp0Distributives"
SET "baseDistributives=%~d0\Distributives"
)
IF EXIST "%baseDistributives%_Download" (
    SET "baseWorkdir=%baseDistributives%_Download"
) ELSE SET "baseLogsDir=%TEMP%\distupdatelogs"
(
FOR /R "%baseDistributives%" %%I IN (".Distributives_Update_Run.All.*") DO CALL "%~dp0rund.cmd" "%%~fI"
FOR /R "%baseDistUpdateScripts%" %%I IN (".Distributives_Update_Run.All.*") DO CALL "%~dp0rund.cmd" "%%~fI"

IF EXIST "%~dpn0.OfficeOnly.cmd" CALL "%~dpn0.OfficeOnly.cmd"
CALL "%~dp0cleanup_status_logs.cmd"

EXIT /B
)
