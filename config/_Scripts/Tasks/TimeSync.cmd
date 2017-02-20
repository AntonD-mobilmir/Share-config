@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

IF EXIST "%SystemRoot%\SysNative\cmd.exe" (SET "System32=%SystemRoot%\SysNative") ELSE SET "System32=%SystemRoot%\System32"
SET "TaskRelPath=Tasks\mobilmir.ru\Force Time Sync"

rem IF NOT DEFINED schedUserName CALL "%~dp0..\AddUsers\AddUser_admin-task-scheduler.cmd" /LeaveExistingPwd
rem IF NOT DEFINED schedUserName CALL :GetCurrentUserName schedUserName

rem IF NOT DEFINED schedUserName SET "schedUserName=SYSTEM"
)
(
rem CALL "%~dp0_Schedule WinVista+ Task.cmd" "%~dp0Tasks.XML.7z" "*" "Force Time Sync.xml" /NP /RU "%schedUserName%"
CALL "%~dp0_Schedule WinVista+ Task.cmd" "%~dp0Tasks.XML.7z" "*" "Force Time Sync.xml" /NP /RU "%USERNAME%"

REM Everyone=*S-1-1-0
"%WinDir%\System32\icacls.exe" "%System32%\%TaskRelPath%" /grant "*S-1-1-0:RX"
rem     read&execute, just "read" isn't enough!
EXIT /B %ERRORLEVEL%
)
