(
@REM coding:OEM
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
	SET "ErrorPresence=0"
    )
)
(
    IF %AutoHotkey_Lib_reentrance% LSS 0 SET /A AutoHotkey_Lib_reentrance=0
    IF "%utilsdir%"=="" SET utilsdir=%srcpath%..\utils\
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
) ELSE (
    IF EXIST "%PrimaryDestination%" IF NOT EXIST "%PrimaryDestination%\*.*" RD "%PrimaryDestination%"
    "%utilsdir%7za.exe" x -aoa -y -o"%PrimaryDestination%" -- "%srcpath%%~n0.7z"||%ErrorCmd%
)
EXIT /B %ErrorPresence%
