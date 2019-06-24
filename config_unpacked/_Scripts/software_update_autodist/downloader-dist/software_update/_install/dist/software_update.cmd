@(REM coding:CP866
REM Scripts runs other scripts from directory and saves status
REM                                     Automated software update scripts
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF DEFINED ProgramFiles^(x86^) (SET "lProgramFiles=%ProgramFiles(x86)%") ELSE SET "lProgramFiles=%ProgramFiles%"

    REM Errorlevels:
    REM >=32767 run again later
    REM >=2 installed unsuccessfully, retry one time
    REM ==1 installed unsuccessfully or successfully with minor problems, no retry should be made
    REM ==0 installed ok

    SET "logsuffix=.log"
    SET "logerrsuffix=.errlog"
    SET "logrunningsuffix=.running"

    SET "RunInteractiveInstalls=0"

    SET "ErrorCmd=EXIT 2"
    SET "today=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%"

    CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" & IF NOT DEFINED DefaultsSource EXIT /B 32010
    
    CALL "%ProgramData%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd" || EXIT /B
    IF NOT DEFINED s_uScripts EXIT /B 32002
)
(
    IF NOT EXIST "%s_uScriptsStatus%" MKDIR "%s_uScriptsStatus%"
    IF NOT EXIST "%s_uScriptsStatus%" EXIT /B 32767
    REM used by Check Update Status.ahk to determine if software_update.cmd started since reboot
    (ECHO %DATE% %TIME%)>"%s_uScriptsStatus%\.running"
    
    CALL :GetDir configDir "%DefaultsSource%"
    
    IF NOT EXIST "%s_uScripts%" IF DEFINED s_usHost (
        %SystemRoot%\System32\net.exe use \\%s_usHost% /Delete
        %SystemRoot%\System32\net.exe use "%s_uScripts%" /Delete
        ECHO.|%SystemRoot%\System32\net.exe use "%s_uScripts%" /USER:"nobody-%COMPUTERNAME%" /PERSISTENT:NO
    )
    IF NOT EXIST "%s_uScripts%" EXIT /B 32003
)
IF NOT "%~1"=="" (
    ECHO Unknown argument: %~1. Aborting>&2
    EXIT /B 32100
)
(
    IF EXIST "%s_uScripts%\..\_install\dist\software_update.cmd" (
        REM selfupdate
        "%SystemRoot%\system32\fc.exe" /B "%~0" "%s_uScripts%\..\_install\dist\software_update.cmd" >NUL 2>&1
        REM One of compared files not exist or somethin more serious
        IF ERRORLEVEL 2 EXIT /B 32200
        REM compared files differ
        IF ERRORLEVEL 1 (
            COPY /B /Y "%s_uScripts%\..\_install\dist\software_update.cmd" "%~0"
            CALL %*
            EXIT /B
        )
    )
    REM %AutohotkeyExe% may still be undefined
    IF NOT EXIST "%configDir%" IF "%configDir:~0,2%"=="\\" CALL :ConnectNetDir "%configDir%"
    IF NOT DEFINED AutohotkeyExe CALL "%configDir%_Scripts\FindAutoHotkeyExe.cmd" || EXIT /B 32020
    REM scripts running once if no error
    FOR /F "usebackq delims=" %%I IN (`DIR /B /ON /A-D "%s_uScripts%\*.*"`) DO IF NOT EXIST "%s_uScriptsStatus%\%%~nxI%logsuffix%" IF NOT EXIST "%s_uScriptsStatus%\%%~nxI%logrunningsuffix%" SET "scriptName=%%~I" & CALL :RunUpdate "%s_uScripts%\%%~I" !
    REM scripts running each time are postponed
    FOR /F "usebackq delims=" %%I IN (`DIR /B /ON /A-D "%s_uScripts%\!*.*"`) DO SET "scriptName=%%~I" & CALL :RunUpdate "%s_uScripts%\%%~I"
    REM scripts errored once are postponed
    FOR /F "usebackq delims=" %%I IN (`DIR /B /ON /A-D "%s_uScripts%\*.*"`) DO IF NOT EXIST "%s_uScriptsStatus%\%%~nxI%logsuffix%" IF EXIST "%s_uScriptsStatus%\%%~nxI%logrunningsuffix%" SET "scriptName=%%~I" & CALL :RunUpdate "%s_uScripts%\%%~I" !
)
(
    MOVE /Y "%s_uScriptsStatus%\.running" "%s_uScriptsStatus%\.log"
    (ECHO Finished %DATE% %TIME%)>>"%s_uScriptsStatus%\.log"
    IF DEFINED s_uScriptsOldLogs (
        IF EXIST "%s_uScriptsOldLogs%" FOR %%I IN ("%s_uScriptsStatus%\*.*") DO IF NOT EXIST "%s_uScripts%\%%~nI" MOVE /Y "%%~I" "%s_uScriptsOldLogs%"
        START "" /LOW %AutohotkeyExe% /ErrorStdOut "%s_uScripts%\..\maint\remove old files.ahk" "%s_uScriptsOldLogs%"
    )
EXIT /B
)
:RunUpdate <script-name> <exclusion-prefix-char>
(
    IF "%scriptName:~0,1%"=="%~2" EXIT /B
    
    SET "logmsi=%s_uScriptsStatus%\%~nx1-msiexec.log"
    SET "log=%s_uScriptsStatus%\%~nx1%logsuffix%"
    
    IF "%~x1"==".reg" (
        REM IF "%scriptName:~-6%"=="32-bit"
        REM ELSE IF "%scriptName:~-6%"=="64-bit"
	ECHO %DATE% %TIME% Importing regfile "%~1"1>>"%s_uScriptsStatus%\%~nx1%logrunningsuffix%"
        REG IMPORT "%~1"
    ) ELSE IF "%~x1"==".cmd" (
	ECHO %DATE% %TIME% Starting %comspec% /C "%~1"1>>"%s_uScriptsStatus%\%~nx1%logrunningsuffix%"
	%comspec% /C %1 1>>"%s_uScriptsStatus%\%~nx1%logrunningsuffix%" 2>&1
    ) ELSE IF "%~x1"==".ahk" (
	ECHO %DATE% %TIME% Starting %AutohotkeyExe% "%~1"1>>"%s_uScriptsStatus%\%~nx1%logrunningsuffix%"
	%AutohotkeyExe% /ErrorStdOut %1 1>>"%s_uScriptsStatus%\%~nx1%logrunningsuffix%" 2>&1
    ) ELSE ECHO Don't have method to run "%1">>"%s_uScriptsStatus%\%~nx1%logrunningsuffix%"
)
(
    (
    	ECHO.
	ECHO %DATE% %TIME% exit error level: %ERRORLEVEL%
    )>>"%s_uScriptsStatus%\%~nx1%logrunningsuffix%"
    IF ERRORLEVEL 32767 (
	ECHO Y | MOVE /Y "%s_uScriptsStatus%\%~nx1%logrunningsuffix%" "%s_uScriptsStatus%\%~nx1%logerrsuffix%"
    ) ELSE IF ERRORLEVEL 2 (
	IF NOT EXIST "%s_uScriptsStatus%\%~nx1%logerrsuffix%" ECHO Y | MOVE /Y "%s_uScriptsStatus%\%~nx1%logrunningsuffix%" "%s_uScriptsStatus%\%~nx1%logerrsuffix%"
    ) ELSE (ECHO Y|MOVE /Y "%s_uScriptsStatus%\%~nx1%logrunningsuffix%" "%log%")
    EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
:ConnectNetDir <path>
FOR /F "delims=\ tokens=1,2" %%A IN ("%~1") DO (
    NET USE "\\%%~A" /DELETE
    NET USE "\\%%~A\%%~B" /DELETE
    NET USE "\\%%~A\%%~B" /USER:"nobody-%COMPUTERNAME%" /PERSISTENT:NO
)
EXIT /B
