@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "sidAuthenticatedUsers=*S-1-5-11"

IF NOT DEFINED Download IF /I "%~1"=="/Unpack" SET "Download=0"
IF NOT DEFINED Download IF /I "%~1"=="/Download" SET "Download=1"
IF NOT DEFINED Download IF /I "%USERNAME%"=="Продавец" SET "Download=1"
IF NOT DEFINED Download IF /I "%USERNAME%"=="Пользователь" SET "Download=1"

SET "dest=%srcpath%bin"
)
IF "%Download%"=="1" (
    ECHO Только скачиваение
    "%ProgramFiles%\Internet Explorer\IEXPLORE.EXE" https://dealer.beeline.ru/dealer/criacx.cab
    EXIT /B
)
(
IF NOT "%secondrun%"=="1" IF NOT "%PROCESSOR_ARCHITECTURE%"=="x86" (
    SET "secondrun=1"
    "%SystemRoot%\SysWOW64\cmd.exe" /C %0 %*
    EXIT /B
)

IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
)
CALL :GetDir ConfigDir "%DefaultsSource%"
IF NOT DEFINED exe7z CALL "%ConfigDir%_Scripts\find7zexe.cmd"
(
%exe7z% x -aoa -o"%dest%" -- "%srcpath%criacx.cab"

FOR %%A IN ("%dest%\*.*") DO (
    CALL :CheckUnregRemove "%SystemRoot%\SysWOW64\%%~nxA"
    CALL :CheckUnregRemove "%SystemRoot%\System32\%%~nxA"
)

"%SystemRoot%\System32\icacls.exe" "%dest%\criacx.ocx" /grant "%sidAuthenticatedUsers%:RX"
"%SystemRoot%\System32\regsvr32.exe" /s "%dest%\criacx.ocx"

EXIT /B
)

:CheckUnregRemove
(
    IF EXIST "%~dp1criacx.ocx" (
	"%SystemRoot%\System32\regsvr32.exe" /u /s "%~dp1criacx.ocx"
	DEL "%~dp1criacx.ocx"
    )
    IF EXIST %1 DEL %1
EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
