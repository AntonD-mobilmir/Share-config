@(REM coding:CP866
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
    IF DEFINED PROCESSOR_ARCHITEW6432 (
        "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
        EXIT /B
    )
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED AutoHotkey_Lib_reentrance SET /A "AutoHotkey_Lib_reentrance=0"

    IF NOT DEFINED ErrorCmd (
	SET "ErrorCmd=SET ErrorPresence=1"
	SET "ErrorPresence="
    )
    SET "utilsdir=%~dp0..\utils\"
    IF NOT DEFINED exename7za (
        SET "exename7za=7za.exe"
        IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "exename7za=7za64.exe"
        IF DEFINED PROCESSOR_ARCHITEW6432 SET "exename7za=7za64.exe"
    )
)
(
    IF NOT DEFINED exe7z SET exe7z="%utilsdir%%exename7za%"

    IF %AutoHotkey_Lib_reentrance% LSS 0 SET /A "AutoHotkey_Lib_reentrance=0"
    IF EXIST "%ProgramFiles%\AutoHotkey" (
	SET "PrimaryDestination=%ProgramFiles%\AutoHotkey\Lib"
    ) ELSE (
	IF EXIST "%ProgramFiles(x86)%\AutoHotkey" SET "PrimaryDestination=%ProgramFiles(x86)%\AutoHotkey\Lib"
    )
)
IF NOT DEFINED PrimaryDestination (
    IF %AutoHotkey_Lib_reentrance% GEQ 2 EXIT /B 0
    SET /A "AutoHotkey_Lib_reentrance+=1"
    CALL "%~dp0..\..\Keyboard Tools\AutoHotkey\install.cmd" || %ErrorCmd%
    REM install_silently will call this script, so do not continue
    IF NOT DEFINED ErrorPresence EXIT /B 0
) ELSE (
    IF EXIST "%PrimaryDestination%" IF NOT EXIST "%PrimaryDestination%\*.*" RD "%PrimaryDestination%"
    %exe7z% x -aoa -y -o"%PrimaryDestination%" -- "%srcpath%%~n0.7z"||%ErrorCmd%
    IF NOT DEFINED ErrorPresence EXIT /B 0
)
EXIT /B %ErrorPresence%
