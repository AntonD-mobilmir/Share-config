@REM coding:OEM
@ECHO OFF
REM Script looks for files under %1 also exist somewhere under %2
REM and removes it from %1 or %2 (by options)
REM Searching done by name, then contents compared
REM For help, see :usage at bottom
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
REM
REM This work by LogicDaemon is licensed under a Creative Commons Attribution 3.0 Unported License.
REM http://creativecommons.org/licenses/by/3.0/

SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0

IF "%~1"=="" GOTO :usage

SET recursively=
SET RemoveReally=
SET deleteWhich=sought
SET sought=
SET searchpath=
SET forceDelRO=

:nextSought
IF "%~1"=="" (
    CALL :RunSearch *.*
    EXIT /B
)
SET argv=%~1

IF "%argv%"=="/?" GOTO :usage

SET argpfx=%argv:~,1%
SET argnm=%argv:~1%

SET FlagValue=1

SET argppfx=%argnm:~,1%
IF "%argppfx%"=="-" (
    SET FlagValue=0
    SET argnm=%argnm:~1%
)

IF "%argpfx%"=="/" (
    GOTO :argnm_%argnm%
    GOTO :badargnm
)

IF "%searchpath%"=="" (
    CALL :SETSearchPathAndMask %1
    GOTO :SoughtCycle
)

CALL :RunSearch

:SoughtCycle
SHIFT
GOTO :nextSought

:RunSearch
    FOR %recursively% %%I IN (%1) DO CALL :LookFor "%%~fI" %%~zI
EXIT /B

:LookFor
    rem It must not be the same file, but size must be the same
    FOR /R "%searchpath%" %%J IN (%searchmask%) DO IF /I %1 NEQ "%%~fJ" IF %2.==%%~zJ. CALL :CompareAskAndRemove %1 "%%~fJ"
EXIT /B

:CompareAskAndRemove
    FC /B %1 %2 >NUL 2>&1
    REM errorlevel 2 - One of compared files not exist or somethin more serious
    REM errorlevel 1 - compared files differ
    IF ERRORLEVEL 1 EXIT /B

    ECHO %1 and %2 no different
    IF "%deleteWhich%"=="sought" SET FileToRemove=%1
    IF "%deleteWhich%"=="found" SET FileToRemove=%2

    IF "%RemoveReally%"=="1" GOTO :DoRemove
    ECHO Would be deleted: %FileToRemove%
    EXIT /B
    :DoRemove
    DEL %forceDelRO% %FileToRemove%
EXIT /B

:SETSearchPathAndMask
    SET searchpath=%~dp1
    SET searchmask=%~nx1
    IF "%searchmask%"=="." SET searchmask=*.*
    IF "%searchmask%"=="" SET searchmask=*.*
EXIT /B

:badargnm
    ECHO Error! Wrong argument: %1
EXIT /B 32768

:argnm_R
    IF "%FlagValue%"=="1" (
	SET recursively=/R
    ) ELSE (
	SET recursively=
    )
GOTO :SoughtCycle

:argnm_D
    SET RemoveReally=%FlagValue%
GOTO :SoughtCycle

:argnm_S
    IF "%FlagValue%"=="1" (
	SET deleteWhich=sought
    ) ELSE (
	SET deleteWhich=found
    )
GOTO :SoughtCycle

:argnm_F
    IF "%FlagValue%"=="1" (
	SET forceDelRO=/F
    ) ELSE (
	SET forceDelRO=
    )
GOTO :SoughtCycle

:usage
    ECHO     Searching and removing duplicates in distinct directories
    ECHO                                             by logicdaemon@gmail.com
    ECHO Usage:
    ECHO 	%0 [/option ...] {"search path and mask"} ["sought mask" [...]]
    ECHO tries to find each file matching [/R=recursively] "sought mask"
    ECHO in "search path and mask" (always recursively)
    ECHO and displays [/-D] or deletes [/D] it
    ECHO.
    ECHO /R	select following sought files recursively
    ECHO /-R	select following sought files non-recursively (default)
    ECHO /D	delete really, not just show files
    ECHO /-D	do not delete, search and show only (default)
    ECHO /S	delete sought files (default)
    ECHO /-S	delete found files, not sought
    ECHO /F	Force deleting of read-only files
    EXIT /B
EXIT /B
