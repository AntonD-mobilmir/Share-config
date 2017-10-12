@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF NOT DEFINED LOCALAPPDATA IF EXIST "%USERPROFILE%\Local Settings\Application Data" SET "APPDATA=%USERPROFILE%\Local Settings\Application Data"
)
(    
    SET "schTaskName=ScriptUpdater-autoupdate"

    %SystemRoot%\System32\fltmc.exe >nul 2>&1
    IF ERRORLEVEL 1 ( REM not admin
	SET "txtScriptUpdaterDir=%LOCALAPPDATA%\mobilmir.ru"
    ) ELSE ( REM Admin
	SET "txtScriptUpdaterDir=%ProgramData%\mobilmir.ru"
	SET "IsAdmin=1"
    )
    
    IF "%~1"=="" (
	IF DEFINED ScriptUpdaterDir (
	    CALL :ScriptUpdaterDirNonDefault
	) ELSE (
	    IF DEFINED IsAdmin ( REM Admin
		IF EXIST "d:\Local_Scripts" (
		    SET "ScriptUpdaterDir=d:\Local_Scripts\ScriptUpdater"
		    SET "taskXML=ScriptUpdater-autoupdate D_Local_Scripts.xml"
		) ELSE (
		    SET "ScriptUpdaterDir=%ProgramData%\mobilmir.ru\ScriptUpdater"
		    SET "taskXML=ScriptUpdater-autoupdate ProgramData.xml"
		)
	    ) ELSE ( REM not admin
		SET "UserIDPrefix=%USERNAME%_"
		SET "ScriptUpdaterDir=%LOCALAPPDATA%\mobilmir.ru"
		REM due to limitation of command length in schtasks command line, have to shorten any paths
		SET "taskScriptUpdaterDir=%%LOCALAPPDATA%%\mobilmir.ru"
		CALL :ScriptUpdaterDirNonDefault
	    )
	)
    ) ELSE (
	SET "ScriptUpdaterDir=%~1"
	CALL :ScriptUpdaterDirNonDefault
    )

    IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
    
    FOR /F "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
    
    CALL "%~dp0..\AddUsers\AddUser_admin-task-scheduler.cmd" /LeaveExistingPwd
)
(
    IF NOT DEFINED taskScriptUpdaterDir SET "taskScriptUpdaterDir=%ScriptUpdaterDir%"
    SET "GNUPGHOME=%ScriptUpdaterDir%\gnupg"
)
@(
    %exe7z% x -aoa -o"%ScriptUpdaterDir%" -- "%~dp0ScriptUpdater.7z" || EXIT /B
    SET "GenKeyring=1"
    FOR %%A IN ("%GNUPGHOME%\secring.gpg") DO IF EXIST "%%~A" IF NOT "%%~zA"=="0" SET "GenKeyring="
    FOR /D %%A IN ("%GNUPGHOME%\private-keys-v*") DO FOR %%B IN ("%%~A\*.key") DO IF NOT "%%~zB"=="0" SET "GenKeyring="
    IF DEFINED GenKeyring CALL "%~dp0..\genGpgKeyring.cmd" "\\Srv0.office0.mobilmir\profiles$\Share\gpg\" "%UserIDPrefix%%Hostname%@ScriptUpdater.mobilmir" "ScriptUpdater" || EXIT /B

    MKDIR "%txtScriptUpdaterDir%" 2>NUL
    ( ECHO %ScriptUpdaterDir%
    )>"%txtScriptUpdaterDir%\ScriptUpdaterDir.txt"
    
    ECHO OFF
    CALL "%~dp0..\Tasks\_Schedule WinVista+ Task.cmd" "%~dp0Tasks.7z" "%schTaskName%" "%taskXML%" /RU "%schedUserName%" /RP "%schedUserPwd%"
    IF DEFINED ModifyTask %SystemRoot%\System32\schtasks.exe /Change /TN "mobilmir.ru\%schTaskName%" /TR "%comspec% /RU "%schedUserName%" /RP "%schedUserPwd%" /C ''%ScriptUpdaterDir%\autoupdate.cmd' >'%TEMP%\ScriptUpdater-autoupdate.log' 2>&1'" <NUL

    EXIT /B
)
:ScriptUpdaterDirNonDefault
(
    rem Parsing ScriptUpdaterDir inline causes 
    rem The syntax of the command is incorrect.
    rem C:\WINDOWS\system32>    IF "~-1ScriptUpdaterDir:~0,-1"
    rem so sub
    IF "%ScriptUpdaterDir:~-1%"=="\" SET "ScriptUpdaterDir=%ScriptUpdaterDir:~0,-1%"
    SET "taskXML=ScriptUpdater-autoupdate ProgramData.xml"
    SET "ModifyTask=1"
EXIT /B
)
