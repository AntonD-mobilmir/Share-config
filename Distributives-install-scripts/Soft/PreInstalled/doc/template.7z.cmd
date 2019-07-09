@(REM coding:CP866
REM Template to install preinstalled and working-without-install software
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    IF NOT EXIST "%utilsdir%\7za.exe" (
        SET "utilsdir="
        FOR %%A IN (".." "..\..") DO IF NOT DEFINED utilsdir IF EXIST "%~dp0%%~A\utils\7za.exe" SET "utilsdir="%~dp0%%~A\utils\"
        IF NOT DEFINED utilsdir (
            ECHO Utilsdir with 7za.exe not found
            EXIT /B 9009
        )
    )
    SET "ProgramFiles32bit=%ProgramFiles%"
    IF DEFINED ProgramFiles^(x86^) SET "ProgramFiles32bit=%ProgramFiles(x86)%"

    SET "OS64Bit="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"
    IF DEFINED OS64Bit ( IF DEFINED ProgramW6432 ( SET "ProgramFiles64bit=%ProgramW6432%" ) ELSE ( SET "ProgramFiles64bit=%ProgramFiles%" ) )
)
(
    IF NOT EXIST "%ProgramFiles32bit%\%~n0" MKDIR "%ProgramFiles32bit%\%~n0"
    "%utilsdir%7za.exe" x -r -aoa "%srcpath%%~n0.7z" -o"%ProgramFiles32bit%\%~n0"
    "%SystemRoot%\System32\compact.exe" /C /S:"%ProgramFiles32bit%\%~n0" /I /Q /EXE:LZX || "%SystemRoot%\System32\compact.exe" /C /S:"%ProgramFiles32bit%\%~n0" /I /Q
)
