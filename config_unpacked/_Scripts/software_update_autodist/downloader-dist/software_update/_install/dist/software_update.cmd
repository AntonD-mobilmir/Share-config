@(REM coding:CP866
REM Scripts runs other scripts from directory and saves status
REM                                     Automated software update scripts
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
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
)
( REM re-bracket due to ProgramData on XP
CALL "%ProgramData%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd" || EXIT /B
IF NOT DEFINED SUScripts EXIT /B 32002
CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
IF NOT DEFINED DefaultsSource EXIT /B 32010
)
(
IF NOT EXIST "%SUScripts%" (
    %SystemRoot%\System32\net.exe use \\%SUSHost% /Delete
    %SystemRoot%\System32\net.exe use "%SUScripts%" /Delete
    ECHO.|%SystemRoot%\System32\net.exe use "%SUScripts%" /USER:nobody-%COMPUTERNAME% /PERSISTENT:NO
)
IF NOT EXIST "%SUScripts%" EXIT /B 32003
IF NOT EXIST "%SUScriptsStatus%" MKDIR "%SUScriptsStatus%" & IF NOT EXIST "%SUScriptsStatus%" EXIT /B 32767
IF NOT EXIST "%SUScriptsOldLogs%" MKDIR "%SUScriptsOldLogs%" & IF NOT EXIST "%SUScriptsOldLogs%" EXIT /B 32767

CALL :GetDir configDir "%DefaultsSource%"
)
CALL "%configDir%_Scripts\FindAutoHotkeyExe.cmd" || EXIT /B 32020
:NextArg
(
IF "%~1"=="" GOTO :NoMoreArgs
ECHO Unknown argument: %~1. Aborting >&2
EXIT /B 32100
SHIFT
GOTO :NextArg
)
:NoMoreArgs
(
REM selfupdate
rem SUScripts=\\%SUSHost%\%SUSPath%\scripts
"%SystemRoot%\system32\fc.exe" /B "%0" "%SUScripts%\..\_install\dist\software_update.cmd" >NUL 2>&1
REM One of compared files not exist or somethin more serious
IF ERRORLEVEL 2 EXIT /B 32200
REM compared files differ
IF ERRORLEVEL 1 COPY /B /Y "%SUScripts%\..\_install\dist\software_update.cmd" "%0" & EXIT /B

REM cleanup
FOR %%I IN ("%SUScriptsStatus%\*.*") DO IF NOT EXIST "%SUScripts%\%%~nI" ECHO Y|MOVE /Y "%%~I" "%SUScriptsOldLogs%"
%AutohotkeyExe% /ErrorStdOut "%SUScripts%\..\_install\dist\remove old logs.ahk" 1>>"%SUScriptsStatus%\%~nx1%logrunningsuffix%" 2>&1
REM scripts running once if no error
FOR /F "usebackq delims=" %%I IN (`DIR /B /ON /A-D "%SUScripts%\*.*"`) DO IF NOT EXIST "%SUScriptsStatus%\%%~nxI%logsuffix%" SET "ScriptName=%%~I" & CALL :RunUpdate "%SUScripts%\%%~I" !
REM scripts running each time
FOR /F "usebackq delims=" %%I IN (`DIR /B /ON /A-D "%SUScripts%\!*.*"`) DO SET "ScriptName=%%~I" & CALL :RunUpdate "%SUScripts%\%%~I"
EXIT /B
)
:RunUpdate <script-name> <exclusion-suffix-char>
(
    IF "%ScriptName:~0,1%"=="%~2" EXIT /B
    
    SET "logmsi=%SUScriptsStatus%\%~nx1-msiexec.log"
    SET "log=%SUScriptsStatus%\%~nx1%logsuffix%"

    IF "%~x1"==".cmd" (
	ECHO %DATE% %TIME% Starting %comspec% /C "%~1"1>>"%SUScriptsStatus%\%~nx1%logrunningsuffix%"
	%comspec% /C %1 1>>"%SUScriptsStatus%\%~nx1%logrunningsuffix%" 2>&1
    ) ELSE IF "%~x1"==".ahk" (
	ECHO %DATE% %TIME% Starting %AutohotkeyExe% "%~1"1>>"%SUScriptsStatus%\%~nx1%logrunningsuffix%"
	%AutohotkeyExe% /ErrorStdOut %1 1>>"%SUScriptsStatus%\%~nx1%logrunningsuffix%" 2>&1
    ) ELSE ECHO Don't have method to run "%1">>"%SUScriptsStatus%\%~nx1%logrunningsuffix%"
)
(
    (
    	ECHO.
	ECHO %DATE% %TIME% exit error level: %ERRORLEVEL%
    )>>"%SUScriptsStatus%\%~nx1%logrunningsuffix%"
    IF ERRORLEVEL 32767 (
	ECHO Y | MOVE /Y "%SUScriptsStatus%\%~nx1%logrunningsuffix%" "%SUScriptsStatus%\%~nx1%logerrsuffix%"
    ) ELSE IF ERRORLEVEL 2 (
	IF NOT EXIST "%SUScriptsStatus%\%~nx1%logerrsuffix%" ECHO Y | MOVE /Y "%SUScriptsStatus%\%~nx1%logrunningsuffix%" "%SUScriptsStatus%\%~nx1%logerrsuffix%"
    ) ELSE (ECHO Y|MOVE /Y "%SUScriptsStatus%\%~nx1%logrunningsuffix%" "%log%")
    EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
