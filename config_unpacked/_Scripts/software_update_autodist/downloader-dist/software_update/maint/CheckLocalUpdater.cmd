@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
)
CALL "%ProgramData%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd"
(
    FOR /F "usebackq delims=" %%A IN (`DIR /B /O-D "%s_uscriptsStatus%\*.*"`) DO (
	SET "lastLog=%s_uscriptsStatus%\%%~A"
	SET "lastLogTime=%s_uscriptsStatus%\%%~tA"
	GOTO :FoundLatest
    )
    IF ERRORLEVEL 1 EXIT /B
    EXIT /B 1
)
:FoundLatest
(
ECHO %lastLog%
)>"%TEMP%\%~n0.flag"
