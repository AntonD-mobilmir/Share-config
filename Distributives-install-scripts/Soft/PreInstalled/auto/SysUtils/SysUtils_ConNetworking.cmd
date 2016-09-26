@(REM coding:CP866
IF NOT DEFINED SysUtilsDir CALL "%~dp0..\_init.cmd"
IF NOT DEFINED SysUtilsDir SET "SysUtilsDir=%SystemDrive%\SysUtils"
IF NOT EXIST "%utilsdir%7za.exe" SET "utilsdir=%~dp0..\..\utils\"
SET "AddToAppPathsAHK=%ProgramData%\mobilmir.ru\Common_Scripts\AddToAppPaths.ahk"
IF NOT DEFINED ErrorCmd (
    SET "ErrorCmd=SET ErrorPresence=1"
    SET "ErrorPresence=0"
)
)
(
"%utilsdir%7za.exe" x -r -aoa -o"%SysUtilsDir%" "%~dpn0.7z" || %ErrorCmd%
IF "%SysUtilsDelaySettings%"=="1" EXIT /B
rem Adding EXEs to App Paths
IF NOT EXIST "%AddToAppPathsAHK%" CALL "%~dp0..\Common_Scripts.cmd"
FOR /R "%SysUtilsDir%" %%I IN (".") DO IF EXIST "%%~fI\*.exe" "%utilsdir%AutoHotkey.exe" /ErrorStdOut "%AddToAppPathsAHK%" "%%~fI\*.exe"
)
