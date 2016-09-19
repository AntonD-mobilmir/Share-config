@(REM coding:CP866
@ECHO OFF
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
SET "SUScripts=%DistUpdRunDir%software_update\scripts"

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
REM --- For All ---
FOR /R "%baseDistributives%" %%I IN (".Distributives_Update_Run.All.*") DO CALL :rund "%%~fI"
FOR /R "%baseDistUpdateScripts%" %%I IN (".Distributives_Update_Run.All.*") DO CALL :rund "%%~fI"

EXIT /b
)

:rund
    (
    SETLOCAL ENABLEDELAYEDEXPANSION
    SET "relDir=%~dp1"
    SET "relDir=!relDir:%baseDistributives%\=\!"
    SET "relDir=!relDir:%baseDistUpdateScripts%\=\!"
    SET "relDir=!relDir:%baseWorkdir%\=\!"
    )
    (
    ENDLOCAL
    SET "relDir=%relDir%"
    )
    IF DEFINED baseLogsDir (
	SET "runlog=%baseLogsDir%%relDir%%~nx1.log"
    ) ELSE (
	IF DEFINED baseWorkdir SET "runlog=%baseWorkdir%%relDir%%~nx1.log"
    )
    CALL :defineRunDir "%runlog%"
    PUSHD "%runDir%" && (
	GOTO :rund%~x1.ext
	rem Extension unknown
	ECHO %DATE% %TIME% [Can't Run "*%~x1", skipped] %*
	POPD
    )
    EXIT /B
:rund.cmd.ext
:rund.bat.ext
    IF NOT EXIST "%TEMP%\y.txt" FOR /L %%I IN (1,1,10) DO ECHO y>>"%TEMP%\y.txt"
    %comspec% /C %* >"%runlog%" 2>&1 <"%TEMP%\y.txt"
    GOTO :rundCheckError
:rund.ahk.ext
    IF NOT DEFINED AutohotkeyExe FOR /F "usebackq tokens=2 delims==" %%A IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
    %AutohotkeyExe% /ErrorStdOut %* >"%runlog%"
    GOTO :rundCheckError
:rundCheckError
    IF ERRORLEVEL 1 (
	ECHO %DATE% %TIME% [Error %ERRORLEVEL%] %*
    ) ELSE (
	ECHO %DATE% %TIME% [OK] %*
    )
    POPD
EXIT /B

:GetFirstArg
    SET %1=%2
EXIT /B

:defineRunDir
    SET "runDir=%~dp1"
    IF NOT EXIST "%runDir%" MKDIR "%runDir%"
EXIT /B
