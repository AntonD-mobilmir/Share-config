@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

CALL "%~dp0..\find7zexe.cmd"
CALL "%~dp0..\find_exe.cmd" SetACLexe SetACL.exe
CALL "%~dp0_Schedule WinVista+ Task.cmd" "%~dp0Tasks.XML.7z" "*"
)
(
rem %ERRORLEVEL% will not change in this block

rem setup permissions
CALL "%~dp0Restart Spooler.cmd"
CALL "%~dp0TimeSync.cmd"

EXIT /B %ERRORLEVEL%
)
