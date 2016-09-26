@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET "lProgramFiles=%ProgramFiles%"
IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"

SET "exegetver=%SystemDrive%\SysUtils\lbrisar\getver.exe"

CALL "%~dp0find_distributive.cmd" || EXIT /B
CALL :find7zexe
)
SET "exeMT=%lProgramFiles%\Mozilla Thunderbird\thunderbird.exe"
IF NOT EXIST "%exeMT%" EXIT /B 2
IF NOT EXIST "%exegetver%" GOTO :skipVerCheck

SET "tempdir=%TEMP%\Thunderbird-update %DATE% %TIME::=%"
%exe7z% e -aoa -o"%tempdir%" -- "%distFullPath%" core\thunderbird.exe

FOR /F "usebackq tokens=1" %%V IN (`%exegetver% "%exeMT%"`) DO SET "mtversion=%%~V"
FOR /F "usebackq tokens=1" %%V IN (`%exegetver% "%tempdir%\thunderbird.exe"`) DO SET "distversion=%%~V"
RD /S /Q %tempdir%

CALL :VersionGreater "%distversion%" "%mtversion%" && EXIT /B 1
:skipVerCheck
CALL "%~dp0install.cmd"
EXIT /B

:find7zexe
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
CALL :GetDir ConfigDir "%DefaultsSource%"
CALL "%ConfigDir%_Scripts\find7zexe.cmd"
EXIT /B
:GetDir
(
    SET "%~1=%~dp2"
    EXIT /B
)
:VersionGreater
(
IF "%~1"=="" EXIT /B
SETLOCAL
rem Compare version by parts as numbers.
rem This is required because string "10." is less (<, LSS) than "5.0".

rem returns 1 if first version provided via command line is greater than second
rem example: CALL :VersionGreater 3.4.5 6.7.8 = ErrorLevel 0
rem example: CALL :VersionGreater 3.4.5 3.4.5 = ErrorLevel 0
rem example: CALL :VersionGreater 6.7.8 3.4.5 = ErrorLevel 1

FOR /F "delims=. tokens=1,2,3,4" %%I IN ("%~2%") DO (
    SET verSub1=%%I
    SET verSub2=%%J
    SET verSub3=%%K
    SET verSub3=%%L
)
FOR /F "delims=. tokens=1,2,3,4" %%I IN ("%~1") DO (
    SET chkSub1=%%I
    SET chkSub2=%%J
    SET chkSub3=%%K
    SET chkSub3=%%L
)
IF NOT DEFINED verSub1 SET verSub1=0
IF NOT DEFINED verSub2 SET verSub2=0
IF NOT DEFINED verSub3 SET verSub3=0
IF NOT DEFINED verSub4 SET verSub4=0
IF NOT DEFINED chkSub1 SET chkSub1=0
IF NOT DEFINED chkSub2 SET chkSub2=0
IF NOT DEFINED chkSub3 SET chkSub3=0
IF NOT DEFINED chkSub4 SET chkSub4=0
)
(
ENDLOCAL
IF %chkSub1% GTR %verSub1% EXIT /B 1
IF %chkSub1% LSS %verSub1% EXIT /B 0
IF %chkSub2% GTR %verSub2% EXIT /B 1
IF %chkSub2% LSS %verSub2% EXIT /B 0
IF %chkSub3% GTR %verSub3% EXIT /B 1
EXIT /B 0
)
