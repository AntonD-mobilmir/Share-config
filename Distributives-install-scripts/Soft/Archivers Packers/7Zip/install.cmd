@(REM coding:CP866
REM Script to silently install 7-Zip, 7za and 7z_extra
REM to the same place and add it to %PATH%.
REM                   by LogicDaemon AKA AntICode <logicdaemon@gmail.com>

IF DEFINED PROCESSOR_ARCHITEW6432 IF NOT DEFINED installreentrance (
    SET "installreentrance=1"
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED ErrorCmd ( SET "ErrorCmd=PAUSE" & IF "%RunInteractiveInstalls%"=="0" SET "ErrorCmd=CALL :HandleError" )
CALL "%~dp0Find7zDir.cmd"
IF NOT DEFINED dest7zinst SET "dest7zinst=%ProgramFiles%\7-Zip"
)
SET "distDir=%srcpath%"
FOR /F "usebackq delims=" %%I IN (`DIR /B /S /O-D "%distDir%7z*.exe"`) DO (
    CALL :SetIfSameWordSizeAsSystem distrib_main "%%~I" && GOTO :breakDistLookup
)
:breakDistLookup
(
ECHO distrib_main=%distrib_main%
IF NOT DEFINED distrib_main %ErrorCmd%
REG DELETE HKEY_CURRENT_USER\Software\7-Zip" /v "Path" /f /reg:64 || REG DELETE HKEY_CURRENT_USER\Software\7-Zip" /v "Path" /f
REG DELETE HKEY_CURRENT_USER\Software\7-Zip" /v "Path32" /f /reg:64 || REG DELETE HKEY_CURRENT_USER\Software\7-Zip" /v "Path32" /f
rem Here been reg add, ditched because caused cmd.exe error on win7 64-bit because of parethensis
"%distrib_main%" /S /D="%dest7zinst%"||%ErrorCmd%

CALL "%srcpath%associate.cmd"
EXIT /B
)
:SetIfSameWordSizeAsSystem <varname> <distname>
(
    rem	7z1506.exe, 7z1506-x64.exe
    SETLOCAL
    SET "distname=%~2"
)
(
    ENDLOCAL
    IF /I "%distname:~-8%" EQU "-x64.exe" (
	IF /I "%PROCESSOR_ARCHITECTURE%" EQU "AMD64" SET "%~1=%distname%" & EXIT /B 0
    ) ELSE IF /I "%PROCESSOR_ARCHITECTURE%" NEQ "AMD64" SET "%~1=%distname%" & EXIT /B 0
rem     on re-use, either ensure this is sysnative\cmd.exe, or check also "%PROCESSOR_ARCHITEW6432%"=="AMD64" 
EXIT /B 1
)

rem REG ADD from before "%distrib_main%" /S

rem Непредвиденное появление: \7-Zip\7zFM.exe\" \"%1\"".
rem C:\Windows>REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Applications\7zFM.exe\sh
rem ell\Open\Command" /ve /t REG_EXPAND_SZ /d "\"C:\Program Files (x86)\7-Zip\7zFM.e
rem xe\" \"%1\"" /f /reg:64

rem REG ADD "HKEY_CURRENT_USER\Software\7-Zip" /v "Path" /d "%dest7zinst%" /f /reg:64 || REG ADD "HKEY_CURRENT_USER\Software\7-Zip" /v "Path" /d "%dest7zinst%" /f
rem REG ADD "HKEY_CURRENT_USER\Software\7-Zip" /v "Path32" /d "%dest7zinst%" /f /reg:64 || REG ADD "HKEY_CURRENT_USER\Software\7-Zip" /v "Path32" /d "%dest7zinst%" /f
