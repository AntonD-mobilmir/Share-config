@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

CALL "%~dp0download.cmd" %*
IF DEFINED s_uscripts FOR /F "usebackq delims=" %%I IN (`DIR /B /O-D "%~dp0AutoHotkey*.exe"`) DO CALL "%s_uscripts%\..\templates\_add_withVer.cmd" "%%~I" & EXIT /B
)
