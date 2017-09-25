@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    
    SET "schTaskName=ScriptUpdater-autoupdate"
    SET "dest=%~1"
    
    IF NOT DEFINED dest (
	IF EXIST "d:\Local_Scripts" (
	    SET "dest=d:\Local_Scripts\ScriptUpdater"
	    SET "taskXML=ScriptUpdater-autoupdate D_Local_Scripts.xml"
	) ELSE (
	    SET "dest=%ProgramData%\mobilmir.ru\ScriptUpdater"
	    SET "taskXML=ScriptUpdater-autoupdate ProgramData.xml"
	)
    ) ELSE CALL :DestOnCmdl
    
    IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
)
(
    MKDIR "%ProgramData%\mobilmir.ru" 2>NUL
    ( ECHO %dest%
    )>"%ProgramData%\mobilmir.ru\ScriptUpdaterDir.txt"
    
    %exe7z% x -aoa -o"%dest%" -- "%~dp0ScriptUpdater.7z"
    SET "GenKeyring=1"
    FOR %%A IN ("%dest%\gnupg\secring.gpg") DO IF EXIST "%%~A" IF NOT "%%~zA"=="0" SET "GenKeyring="
    FOR /D %%A IN ("%dest%\gnupg\private-keys-v*") DO FOR %%B IN ("%%~A\*.key") DO IF NOT "%%~zB"=="0" SET "GenKeyring="
    IF DEFINED GenKeyring CALL "%dest%\genGpgKeyring.cmd"
    
    CALL "%~dp0..\Tasks\_Schedule WinVista+ Task.cmd" "%~dp0Tasks.7z" "%schTaskName%" "%taskXML%"
    IF DEFINED ModifyTask %SystemRoot%\System32\schtasks.exe /Change /TN "mobilmir.ru\%schTaskName%" /TR "%comspec% /C ''%dest%\autoupdate.cmd' >'%TEMP%\ScriptUpdater-autoupdate.log' 2>&1'"
    
    EXIT /B
)
:DestOnCmdl
(
    rem Parsing DEST inline causes 
    rem The syntax of the command is incorrect.
    rem C:\WINDOWS\system32>    IF "~-1dest:~0,-1"
    rem so sub
    IF "%dest:~-1%"=="\" SET "dest=%dest:~0,-1%"
    SET "taskXML=ScriptUpdater-autoupdate ProgramData.xml"
    SET "ModifyTask=1"
EXIT /B
)
