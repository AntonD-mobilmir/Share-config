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

SET "localconfigpath=%LOCALAPPDATA%\Microsoft\Windows\FileHistory\Configuration"
SET "remoteconfigpath=\\localhost\File History$\%USERNAME%\%COMPUTERNAME%\Configuration"

CALL "%~dp0..\FindAutoHotkeyExe.cmd"
)
(
rem as user:
MKDIR "%localconfigpath%"
%AutoHotkeyExe% "%~dp0FillInTemplate.ahk"
COPY /B /Y "%localconfigpath%\Config1.xml" "%localconfigpath%\Config2.xml"

rem MKDIR "%remoteconfigpath%"
rem XCOPY "%localconfigpath%\config?.xml" "%remoteconfigpath%" /E /I /H /Y

rem as admin:
rem powershell.exe -Command "Start-Process -FilePath \"%comspec%\" -ArgumentList \"/C `\"`\"%~dp0File History setup admin.cmd`\" `\"%localconfigpath%`\"`\"\" -Verb RunAs"
)
