@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "outFile=groups-depts-co %DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%.txt"
)
IF EXIST "%outFile%" ECHO. >>"%outFile%"
(
    ECHO %DATE% %TIME%
    FOR /F "usebackq" %%I IN (`gam print groups`) DO (
	SET "GroupName=%%~I"
	CALL :CheckGroup
    )
EXIT /B
) >>"%outFile%"
:CheckGroup
(
    IF "%GroupName:~0,9%"=="depts-co-" CALL gam info group "%GroupName%"
EXIT /B
)
