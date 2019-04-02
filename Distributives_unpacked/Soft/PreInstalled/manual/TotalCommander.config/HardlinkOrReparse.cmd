@(REM coding:CP866
ECHO OFF
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
    SET "ErrorsHappened="
    SET "dst=%~2"
    FOR /F "usebackq delims=" %%I IN (%1) DO (
	SET "src=%%~I"
	SET "srcnx=%%~nxI"
	CALL :Link
    )
    IF DEFINED ErrorsHappened (
	ECHO 
	PING 127.0.0.1 -n 60 >NUL
    ) ELSE EXIT /B 0
)
EXIT /B %ErrorsHappened%
:Link
IF NOT DEFINED srcnx CALL :setsrcnx "%src:~0,-1%" & REM "%srcnx%"="" when %%~I ends with \
IF NOT "%dst:~-1%"=="\" SET "dst=%dst%\" & REM should only happen once
(
    IF "%src:~-1%"=="\" ( REM source is a directory
	MKLINK /D "%dst%%srcnx%" "%src:~0,-1%" || MKLINK /J "%dst%%srcnx%" "%src:~0,-1%" || "%COMMANDER_PATH%\xln.exe" -n "%src:~0,-1%" "%dst%%srcnx%"
    ) ELSE (
	rem fsutil requires admin rights --
	MKLINK /H "%dst%%srcnx%" "%src:~0,-1%" || MKLINK "%dst%%srcnx%" "%src:~0,-1%" || "%COMMANDER_PATH%\xln.exe" "%src:~0,-1%" "%dst%%srcnx%" || fsutil hardlink create "%dst%%~nx1" %1
    )
    IF ERRORLEVEL 1 GOTO :ShowError
EXIT /B
)
:ShowError
(
    REM ECHO Error %ERRORLEVEL% linking "%src%" to "%dst%%srcnx%"
    SET "ErrorsHappened=%ErrorsHappened%, "%srcnx%": %ERRORLEVEL%"
    EXIT /B
)
:setsrcnx
(
    SET "srcnx=%~nx1"
EXIT /B
)
