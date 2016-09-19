@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

REM written using http://www.verboon.info/2012/04/windows-8-file-history-feature-replaces-previous-versions-and-backup-and-restore/
REM http://randomthoughtsofforensics.blogspot.ru/2014/12/file-history-research-part-1.html
REM and http://superuser.com/questions/1044050/configuring-windows-8-8-1-10-file-history-via-command-line?noredirect=1#comment1461681_1044050

SET "localconfigpath=%LOCALAPPDATA%\Microsoft\Windows\FileHistory\Configuration\Config"
SET "remoteconfigpath=\\localhost\File History$\%USERNAME%\%COMPUTERNAME%\Configuration"
)
(
rem as admin:
rem CALL "%~dp0share File History for Windows 8.cmd"
rem %SystemRoot%\System32\sc.exe config fhsvc start= delayed-auto
rem REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\fhsvc\Parameters\Configs" /v "%localconfigpath%" /t REG_DWORD /d 1 /f
)
(
rem as user:
MKDIR "%localconfigpath%"
XCOPY "%~dp0File History config template" "%localconfigpath%" /E /I /H /Y
MKDIR "%remoteconfigpath%"
XCOPY "%~dp0File History config template" "%remoteconfigpath%" /E /I /H /Y
)
