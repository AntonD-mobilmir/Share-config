@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

IF NOT EXIST R:\ EXIT /B 1

IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
CALL :Findzpaq || EXIT /B
rem || CALL :Find7z

SET "datey=%DATE:~-4,4%"
SET "exclusionszpaq=-not *:*:$DATA -not *.mp? -not *.avi -not *.mkv -not *.exe -not *.dll -not *.nm7 -not *.apk"

FOR /D %%A IN ("D:\Users\*.*") DO CALL :PackFromDir "%%~A\.Archive-Pack"
EXIT /B
)
:PackFromDir
(
    IF NOT EXIST %1 EXIT /B
    SET "packDestDir=R:%~p1"
)
(
    IF NOT EXIST "%packDestDir%" MKDIR "%packDestDir%"
    START "zpaq a" /B /WAIT /LOW %zpaqexe% a "%packDestDir%%datey%.zpaq" "\\?\%~1\*" -m1 %exclusionszpaq% >>"%packDestDir%zpaq.log" 2>&1 && RD /S /Q "\\?\%~1"
    EXIT /B
)
:Findzpaq
(
    SET "OS64bit="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	SET "OS64bit=1"
	SET zpaqexe="%ProgramFiles%\zpaq\zpaq64.exe"
    ) ELSE IF DEFINED PROCESSOR_ARCHITEW6432 (
	SET "OS64bit=1"
	SET zpaqexe="%ProgramW6432%\zpaq\zpaq64.exe"
    ) ELSE SET zpaqexe="%ProgramFiles%\zpaq\zpaq.exe"
)
(
    IF EXIST %zpaqexe% EXIT /B 0
    SET "zpaqexe="
    IF NOT DEFINED configDir CALL :GetDir configDir "%DefaultsSource%"
)
(
    IF DEFINED OS64bit CALL "%configDir%_Scripts\find_exe.cmd" zpaqexe zpaq.exe
    IF NOT DEFINED zpaqexe CALL "%configDir%_Scripts\find_exe.cmd" zpaqexe zpaq.exe
    EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
