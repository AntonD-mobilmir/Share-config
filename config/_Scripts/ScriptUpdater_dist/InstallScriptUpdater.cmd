@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    SET "schTaskName=ScriptUpdater-autoupdate"
    IF "%~1"=="" (
	IF EXIST "d:\Local_Scripts" (
	    SET "dest=d:\Local_Scripts\ScriptUpdater"
	    SET "taskXML=ScriptUpdater-autoupdate D_Local_Scripts.xml"
	) ELSE (
	    SET "dest=%ProgramData%\mobilmir.ru\ScriptUpdater"
	    SET "taskXML=ScriptUpdater-autoupdate ProgramData.xml"
	)
    ) ELSE SET "dest=%~1"
    IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
)
(
    %exe7z% x -aoa -o"%dest%" -- "%~dp0ScriptUpdater.7z"
    SET "GenKeyring="
    FOR %%A IN ("%dest%\gnupg\secring.gpg") DO (
	IF NOT EXIST "%%~A" SET "GenKeyring=1"
	IF %%~zA. EQU 0. SET "GenKeyring=1"
    )
    IF DEFINED GenKeyring CALL "%dest%\genGpgKeyring.cmd"

    CALL "%~dp0..\Tasks\_Schedule WinVista+ Task.cmd" "%~dp0Tasks.7z" "%schTaskName%" "%taskXML%"
)
