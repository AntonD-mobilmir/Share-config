@(REM coding:CP866
REM coding:OEM
REM Script copies software_update scripts and creates scheduler task
REM on local or target host
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF NOT DEFINED ErrorCmd SET "ErrorCmd=PAUSE"

CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
)
:NextArg
(
    IF "%~1"=="" GOTO :NoMoreArgs
    IF /I "%~1"=="/InstallAndMark" (
	SET InstallAndMark=1
	SHIFT
	GOTO :NextArg
    )
    FOR /F "usebackq tokens=1* delims=\" %%I IN ('%~1') DO (
	SET desthost=%%I
	SET sharename=%%J
    )
)
:NoMoreArgs
(
    IF "%sharename%"=="" (SET "destpath=\\%~1\c$") ELSE "SET destpath=%~1"
    CALL "%srcpath%dist\_get_SoftUpdateScripts_source.cmd"
    CALL :GetDir configDir "%DefaultsSource%"
)
(
    REM use user named admin-task-scheduler with random password, write password to an encrypted local file, use this password for tasks creation
    REM not in retail, because there server can have admin-task-scheduler user too -- IF NOT DEFINED schedUserName CALL "%configDir%_Scripts\AddUsers\AddUser_admin-task-scheduler.cmd" /LeaveExistingPwd
    IF NOT DEFINED schedUserName CALL :GetCurrentUserName schedUserName
)
:SchtasksRepeat
(
    IF NOT DEFINED schedUserName IF NOT "%destpath%"=="" (
	ECHO Пользователь, от имени которого запускаются обновления, должен иметь доступ
	ECHO     для чтения %SUScripts%,
	ECHO     для записи в %SUScripts%\status\%desthost% ^(локально^)
	ECHO     и для создания этих папок, если они не существуют.
	SET /P "schedUserName=Имя пользователя, от которого будет запускаться задача обновления: "
    )
)
(
    rem schedUserName	schedUserPwd
    SET "swSchtasksPass="
    IF DEFINED schedUserPwd SET "swSchtasksPass=/RP ^"%schedUserPwd%^""
    IF "%desthost%"=="" (
	IF NOT EXIST "%ProgramData%\mobilmir.ru" MKDIR "%ProgramData%\mobilmir.ru"||%ErrorCmd%
	COPY /B "%srcpath%dist\*.cmd" "%ProgramData%\mobilmir.ru\*.*"
    ) ELSE (
	IF NOT EXIST "%destpath%\ProgramData\mobilmir.ru" MKDIR "%destpath%\ProgramData\mobilmir.ru"
	COPY /B "%srcpath%dist\*.cmd" "%destpath%\ProgramData\mobilmir.ru\*.*"
	SET schTasksRemote=/S %desthost%
	SC \\%desthost% START RemoteRegistry
    )
)
(
    CALL "%configDir%_Scripts\CheckWinVer.cmd" 6.1 && (
	ECHO Adding software_update_Win7Task_1.2.xml
	"%SystemRoot%\System32\schtasks.exe" %schTasksRemote% /Delete /TN "mobilmir\SoftwareUpdate" /F
	START "schtasks.exe" /WAIT "%SystemRoot%\System32\schtasks.exe" %schTasksRemote% /Create /TN "mobilmir.ru\SoftwareUpdate" /XML "%srcpath%dist\software_update_Win7Task_1.2.xml" /RU "%schedUserName%" %swSchtasksPass% /F
	GOTO :CheckSchtasksError
    )
    CALL "%configDir%_Scripts\CheckWinVer.cmd" 6 && (
	ECHO Adding software_update_Vista_1.2.xml
	"%SystemRoot%\System32\schtasks.exe" %schTasksRemote% /Delete /TN "mobilmir\SoftwareUpdate" /F
	START "schtasks.exe" /WAIT "%SystemRoot%\System32\schtasks.exe" %schTasksRemote% /Create /TN "mobilmir.ru\SoftwareUpdate" /XML "%srcpath%dist\software_update_Vista_1.2.xml" /RU "%schedUserName%" %swSchtasksPass% /F
	GOTO :CheckSchtasksError
    )
    CALL "%configDir%_Scripts\CheckWinVer.cmd" 5 && (
	ECHO Adding SoftwareUpdate.job
	IF "%desthost%"=="" (
	    COPY /B "%srcpath%dist\SoftwareUpdate.job" "%SystemRoot%\Tasks\*.*"
	) ELSE (
	    COPY /B "%srcpath%dist\SoftwareUpdate.job" "\\%desthost%\Admin$\Tasks\*.*"
	)
	"%SystemRoot%\System32\schtasks.exe" %schTasksRemote% /Change /TN SoftwareUpdate /RU "%schedUserName%" %swSchtasksPass%
	GOTO :CheckSchtasksError
    )
)
:CheckSchtasksError
(
IF NOT ERRORLEVEL 1 GOTO :AfterSchtasks
SET "schedUserName="
SET "schtasksRepeat="
SET /P "schtasksRepeat=Ошибка: %ERRORLEVEL%. Повторить? [1=yes=да]"
)
(
IF /I "%schtasksRepeat:~0,1%"=="1" GOTO :SchtasksRepeat
IF /I "%schtasksRepeat:~0,1%"=="Y" GOTO :SchtasksRepeat
IF /I "%schtasksRepeat:~0,1%"=="д" GOTO :SchtasksRepeat
)

:AfterSchtasks
IF "%desthost%"=="" IF NOT "%InstallAndMark%"=="1" EXIT /B
"%SystemRoot%\System32\schtasks.exe" %schTasksRemote% /Run /TN SoftwareUpdate
"%SystemRoot%\System32\schtasks.exe" %schTasksRemote% /Run /TN mobilmir.ru\SoftwareUpdate
EXIT /B
rem CALL "%ProgramData%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd" || (%ErrorCmd% & EXIT /B)
rem FOR %%I IN ("%SUScripts%\*.*") DO IF NOT EXIST "%SUScriptsStatus%\%%~nxI.log" SET "ScriptName=%%~I" & CALL :MarkUpdate "%SUScripts%\%%~I"
rem EXIT /B
rem :MarkUpdate <ScriptName>
rem IF NOT "%ScriptName:~0,1%"=="_" IF NOT "%ScriptName:~0,1%"=="!" ECHO %DATE% %TIME% Marked on install>>"%SUScriptsStatus%\%~nx1.log"
rem EXIT /B

:GetDir <var> <path>
(
    SET "%~1=%~dp2"
EXIT /B
)
:GetCurrentUserName <varname>
IF NOT DEFINED whoamiexe CALL "%configDir%_Scripts\find_exe.cmd" whoamiexe "%SystemDrive%\SysUtils\UnxUtils\whoami.exe"
(
    FOR /F "usebackq delims=\ tokens=2" %%I IN (`%whoamiexe%`) DO SET "%~1=%%~I"
    IF NOT DEFINED %~1 SET "%~1=%USERNAME%"
    EXIT /B
)
