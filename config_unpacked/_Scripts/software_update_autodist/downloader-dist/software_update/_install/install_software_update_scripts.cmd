@(REM coding:CP866
REM Script copies software_update scripts and creates scheduler task
REM on local or target host
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED ErrorCmd SET "ErrorCmd=PAUSE"

CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"

    IF NOT "%~1"=="" (SET "destpath=%~1" & CALL :CheckDestPath)
    CALL :Write_get_SoftUpdateScripts_source
)
:NoMoreArgs
(
    CALL :GetDir configDir "%DefaultsSource%"
    REM use user named admin-task-scheduler with random password, write password to an encrypted local file, use this password for tasks creation
    IF EXIST "%srcpath%dist\SoftUpdateScripts_source.txt" IF NOT DEFINED schedUserName CALL "%configDir%_Scripts\AddUsers\AddUser_admin-task-scheduler.cmd" /LeaveExistingPwd
    IF NOT DEFINED schedUserName CALL :GetCurrentUserName schedUserName
)
:SchtasksRepeat
(
    IF NOT DEFINED schedUserName IF NOT "%destpath%"=="" (
	ECHO ���짮��⥫�, �� ����� ���ண� ����᪠���� ����������, ������ ����� �����
	ECHO     ��� �⥭�� %s_uscripts%,
	ECHO     ��� ����� � %s_uscriptsStatus%
	SET /P "schedUserName=��� ���짮��⥫�, �� ���ண� �㤥� ����᪠���� ����� ����������: "
    )
)
(
    rem schedUserName	schedUserPwd
    SET "swSchtasksPass="
    SET "STARTMode="
    IF DEFINED schedUserPwd (
	SET "swSchtasksPass=/RP ^"%schedUserPwd%^""
	SET "STARTMode=/B"
    )
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
	ECHO Adding software_update_Win7Task_1.2.xml
	"%SystemRoot%\System32\schtasks.exe" %schTasksRemote% /Delete /TN "mobilmir\SoftwareUpdate" /F
	START "schtasks.exe" %STARTMode% /WAIT "%SystemRoot%\System32\schtasks.exe" %schTasksRemote% /Create /TN "mobilmir.ru\SoftwareUpdate" /XML "%srcpath%dist\software_update_Win7Task_1.2.xml" /RU "%schedUserName%" %swSchtasksPass% /F
	GOTO :CheckSchtasksError
)
:CheckSchtasksError
(
IF NOT ERRORLEVEL 1 GOTO :AfterSchtasks
SET "schedUserName="
SET "schtasksRepeat="
SET /P "schtasksRepeat=�訡��: %ERRORLEVEL%. �������? [1=yes=��]"
)
(
IF /I "%schtasksRepeat:~0,1%"=="1" GOTO :SchtasksRepeat
IF /I "%schtasksRepeat:~0,1%"=="Y" GOTO :SchtasksRepeat
IF /I "%schtasksRepeat:~0,1%"=="�" GOTO :SchtasksRepeat
)

:AfterSchtasks
(
    IF NOT "%desthost%"=="" "%SystemRoot%\System32\schtasks.exe" %schTasksRemote% /Run /TN "mobilmir.ru\SoftwareUpdate"
EXIT /B
)
:Write_get_SoftUpdateScripts_source
(
    rem CALL "%srcpath%dist\_get_SoftUpdateScripts_source.cmd"
    IF NOT EXIST "%ProgramData%\mobilmir.ru" MKDIR "%ProgramData%\mobilmir.ru"
    COPY /B "%srcpath%dist\_get_SoftUpdateScripts_source.cmd" "%ProgramData%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd"

    IF NOT EXIST "%srcpath%dist\SoftUpdateScripts_source.txt" GOTO :srcpath_Write_get_SoftUpdateScripts_source

    CALL "%srcpath%dist\_get_SoftUpdateScripts_source.cmd"
    IF NOT DEFINED s_uscripts GOTO :srcpath_Write_get_SoftUpdateScripts_source
)
IF EXIST "%s_uscripts%" (
    COPY /B "%srcpath%dist\SoftUpdateScripts_source.txt" "%ProgramData%\mobilmir.ru\*.*"
    EXIT /B 0
) ELSE (
    SET "s_uscripts="
)
:srcpath_Write_get_SoftUpdateScripts_source
(
    IF "%srcpath:~0,2%"=="\\" (    
        FOR /F "delims=\ tokens=1*" %%A IN ("%srcpath%..") DO @(
            IF "%%~A"=="" (ECHO. ) ELSE ECHO %%~A
            IF NOT "%%~B"=="" ECHO %%~B
        )>"%ProgramData%\mobilmir.ru\SoftUpdateScripts_source.txt"
    ) ELSE (
        @(
            ECHO.
            ECHO %srcpath%..
        )>"%ProgramData%\mobilmir.ru\SoftUpdateScripts_source.txt"
    )
    CALL "%ProgramData%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd"
EXIT /B
)
:CheckDestPath
(
    IF NOT "%destpath:~0,2%"=="\\" EXIT /B
    
    FOR /F "usebackq tokens=1* delims=\" %%I IN ('%~1') DO (
	SET "desthost=%%~I"
	SET "destShareSubdir=%%~J"
    )
    IF NOT DEFINED destShareSubdir SET "destShareSubdir=c$\ProgramData\mobilmir.ru"
)
(
    SET "destpath=\\%desthost%\%destShareSubdir%"
EXIT /B
)
:GetDir <var> <path>
(
    SET "%~1=%~dp2"
EXIT /B
)
:GetCurrentUserName <varname>
IF NOT DEFINED whoamiexe CALL "%configDir%_Scripts\find_exe.cmd" whoamiexe "%SystemDrive%\SysUtils\UnxUtils\whoami.exe"
(
    IF DEFINED whoamiexe (
        FOR /F "usebackq delims=\ tokens=2" %%I IN (`%whoamiexe%`) DO SET "%~1=%%~I"
    ) ELSE (
        IF NOT DEFINED %~1 SET "%~1=%USERNAME%"
    )
EXIT /B
)
