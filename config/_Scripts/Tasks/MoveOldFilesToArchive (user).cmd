@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

IF EXIST "%SystemRoot%\SysNative\cmd.exe" (SET "System32=%SystemRoot%\SysNative") ELSE SET "System32=%SystemRoot%\System32"
SET AddArgs=/RU "%~1" /IT
CALL :ScheduleSingleTask "MoveOldFilesToArchive (%~1)" "%~dp0Tasks\MoveOldFilesToArchive (user).xml"
SET AddArgs=/RU "" /NP
CALL :ScheduleSingleTask "MoveOldFilesToArchive PackArchive" "%~dp0Tasks\MoveOldFilesToArchive PackArchive.xml"
EXIT /B
)
:ScheduleSingleTask <TaskName> <XML>
(
    ECHO.|%System32%\SCHTASKS.exe /Create /TN "mobilmir.ru\%~1" /XML %2 %AddArgs% /F
    IF ERRORLEVEL 1 EXIT /B
    REM Everyone=*S-1-1-0
    "%WinDir%\System32\icacls.exe" "%System32%\Tasks\mobilmir.ru\%~1" /grant "*S-1-1-0:RX"
    EXIT /B
)
