@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
)
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
CALL :mkBaseDir "%runlog%"
PUSHD "%runDir%" && (
    ECHO Executing "%~1"...
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
(
    IF ERRORLEVEL 1 (
	ECHO %DATE% %TIME% [Error %ERRORLEVEL%] %*
    ) ELSE (
	ECHO %DATE% %TIME% [OK] %*
    )
    POPD
EXIT /B
)
:GetFirstArg
(
    SET "%1=%2"
EXIT /B
)
:mkBaseDir
(
    IF NOT EXIST "%~dp1" MKDIR "%~dp1"
    SET "runDir=%~dp1"
EXIT /B
)
