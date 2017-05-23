@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED LOCALAPPDATA IF EXIST "%USERPROFILE%\Local Settings\Application Data" SET "LOCALAPPDATA=%USERPROFILE%\Local Settings\Application Data"
SET "UIDCreatorOwner=S-1-3-0;s:y"
)
CALL "%~dp0FSACL_Change.cmd" "%UIDCreatorOwner%" "%LOCALAPPDATA%\Apps"
