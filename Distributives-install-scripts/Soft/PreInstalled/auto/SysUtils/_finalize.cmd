@(REM coding:CP866
REM part of script-set to install preinstalled and working-without-install software
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

SET "AddToAppPathsAHK=%ProgramData%\mobilmir.ru\Common_Scripts\AddToAppPaths.ahk"
REM skip initial semicolon
IF DEFINED pathString CALL :FilterPaths
IF NOT DEFINED filteredPathString GOTO :SkipAddingPath
)
IF "%filteredPathString:~0,1%"==";" SET "filteredPathString=%filteredPathString:~1%"
(
SET "PATH=%PATH%;%filteredPathString%"
"%utilsdir%AutoHotkey.exe" "%utilsdir%pathman.ahk" /as "%filteredPathString%"
)
:SkipAddingPath
(
rem Adding EXEs to App Paths
IF NOT EXIST "%AddToAppPathsAHK%" CALL "%~dp0Common_Scripts.cmd"
FOR /R "%SysUtilsDir%" %%I IN (.) DO IF EXIST "%%~fI\*.exe" "%utilsdir%AutoHotkey.exe" /ErrorStdOut "%AddToAppPathsAHK%" "%%~fI\*.exe"
EXIT /B
)
:FilterPaths
(
    FOR /F "delims=; tokens=1*" %%A IN ("%pathString%") DO (
	SET "pathString=%%~B"
	IF EXIST "%%~A" CALL :CheckInPathAlready "%%~A" && SET "filteredPathString=%filteredPathString%;%%~A"
    )
    IF DEFINED pathString GOTO :FilterPaths
    EXIT /B
)
:CheckInPathAlready
(
    SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
    IF "%PATH%;"=="!PATH:%~1;=!" EXIT /B 0
    EXIT /B 1
)
