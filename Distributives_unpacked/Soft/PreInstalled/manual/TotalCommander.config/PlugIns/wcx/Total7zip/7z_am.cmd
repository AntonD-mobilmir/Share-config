@(REM coding:CP866
REM 7z-am main file
REM 
REM Theese scripts
REM run 7z with different arguments to gain maximum compression,
REM then compare results'size, deleting all but one smallest,
REM and test the last one at end.
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

ECHO OFF
SETLOCAL ENABLEEXTENSIONS
rem ENABLEDELAYEDEXPANSION
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

REM Setting defaults
IF NOT DEFINED exe7z SET exe7z="%~dp07zG.exe"
IF NOT DEFINED leaveSmallestOnly SET "leaveSmallestOnly=1"
IF NOT DEFINED deleteAfter SET "deleteAfter=0"
IF NOT DEFINED smallestNoSuffix SET "smallestNoSuffix=0"
REM 82 bytes is size of 7z archive containing 1 empty folder
IF NOT DEFINED minArcSize SET "minArcSize=82"
REM   compression parameters and methods defaults
CALL "%~dp07z_get_switches.cmd"

rem --debug--
rem CALL :readSwitches %*
rem PAUSE
rem EXIT /B
)
:readSwitches
SET "curSwitch=%~1"
IF NOT DEFINED curSwitch (
    GOTO :endcycle
) ELSE (
    REM -- - stop switches processing
    IF "%curSwitch:~0,2%" EQU "--" GOTO :next
    REM if first symbol is - or / then this is switch
    SET "FlagChar=%curSwitch:~0,1%"
    SET "curSwitch=%curSwitch:~1%"
)
(
    IF "%FlagChar%" EQU "/" GOTO :processSwitch
    IF "%FlagChar%" EQU "-" GOTO :processSwitch
    REM else this is pathname
    GOTO :next
)
:processSwitch
(
    SHIFT
    REM assume negative modificator ("NO" or "N") is used
    SET "switchMeaning=0"
    SET "switchVarName="
    IF "%curSwitch:~0,2%" EQU "NO" (
	REM SET "switchMeaning=0"
	REM without comma, :~ returns till end of string
	SET "curSwitch=%curSwitch:~2%"
    ) ELSE IF "%curSwitch:~0,1%" EQU "N" (
	REM SET "switchMeaning=0"
	SET "curSwitch=%curSwitch:~1%"
    ) ELSE (
	REM negative modificator is not actually used
	SET "switchMeaning=1"
    )
)
(
    FOR /F "usebackq delims== tokens=1" %%I IN (`set z7zusedeflt`) DO (
	REM then list and check 7zusedeflt* variables and change them if argument is appropriate
	IF /I "z7zusedeflt%curSwitch%" EQU "%%I" (
	    SET "z7zusedeflt%curSwitch%=%switchMeaning%"
	    GOTO :readSwitches
	)
    )
    IF /I "%curSwitch%"=="DELETEAFTER" (		SET "switchVarName=deleteAfter"
    ) ELSE IF /I "%curSwitch%"=="DA" (			SET "switchVarName=deleteAfter"
    ) ELSE IF /I "%curSwitch%"=="SMALLESTNOSUFFIX" (	SET "switchVarName=smallestNoSuffix"
    ) ELSE IF /I "%curSwitch%"=="SNS" (			SET "switchVarName=smallestNoSuffix"
    ) ELSE (
	REM Checking inverted swtiches
	SET /A "switchMeaning=1-%switchMeaning%"
	IF /I "%curSwitch%"=="LEAVEALL" (		SET "switchVarName=leaveSmallestOnly"
	) ELSE IF /I "%curSwitch%"=="LA" (		SET "switchVarName=leaveSmallestOnly" )
    )
)
(
    IF DEFINED switchVarName (
	SET "%switchVarName%=%switchMeaning%"
	GOTO :readSwitches
    )
    rem --not needed-- GOTO :cmdswitch_%curSwitch%
    REM switch is unknown. Treat it as pathname.
    GOTO :next
)
:next
PUSHD "%~1" && (
    CALL :processPath Dir "%~f1"
    POPD
    REM POPD does not change errorlevel
    IF NOT ERRORLEVEL 1 IF "%deleteAfter%"=="1" RD /S /Q "%~f1"
    GOTO :endcycle
)
:notaDirectory
(
    CALL :processPath File "%~1"
    IF NOT ERRORLEVEL 1 IF NOT "%~x1"==".7z" IF "%deleteAfter%"=="1" DEL "%~1"
    GOTO :endcycle
)
:endcycle
(
    REM exit if no more arguments
    IF "%~2"=="" EXIT /B
    REM there are, process them
    SHIFT
    GOTO :next
)
:processPath
(
    SET "archiveslist="
    FOR /F "usebackq delims== tokens=1*" %%I IN (`set z7zusedeflt`) DO (
	IF "%%J"=="1" (
	    SET "z7zmethodVar=%%~I" && CALL :SetArchivingParameters %2 || (ECHO Failed to get archiving parameters.&EXIT /B)
	    CALL :run7z%~1 %2 || (ECHO %exe7z% returned error.&EXIT /B)
	)
    )
)
IF "%leaveSmallestOnly%"=="1" CALL :leaveSmallestOnlyTestsmallest %archiveslist%
(
    REM "%smallest%" modified in :leaveSmallestOnlyTestsmallest
    IF "%smallestNoSuffix%"=="1" CALL :renameNoSuffix "%smallest%"
    EXIT /B
)
:SetArchivingParameters
SET "arcname=%~1"
(
    IF "%arcname:~-1%"=="\" SET "arcname=%arcname:~0,-1%"
    REM without comma, :~ returns till end of string
    SET "z7zmethodName=%z7zmethodVar:~11%"
    FOR /F "usebackq delims== tokens=1*" %%I IN (`SET z7zSwitches%z7zmethodName%`) DO (
	SET "z7zSwitches=%%J"
	EXIT /B
    )
    EXIT /B 1
)
:run7zDir
(
ECHO %exe7z% a -r %z7zSwitches% -- "%arcname%.%z7zmethodName%.7z"
START "Compressing [%z7zmethodName%] to %arcname%.%z7zmethodName%.7z" /BELOWNORMAL /B /WAIT %exe7z% a -r %z7zSwitches% -- "%arcname%.%z7zmethodName%.7z"
SET archiveslist=%archiveslist% "%arcname%.%z7zmethodName%.7z"
EXIT /B
)
:run7zFile
(
ECHO %exe7z% a %z7zSwitches% -- "%arcname%.%z7zmethodName%.7z" %1
START "Compressing [%z7zmethodName%] to %arcname%.%z7zmethodName%.7z" /BELOWNORMAL /B /WAIT %exe7z% a %z7zSwitches% -- "%arcname%.%z7zmethodName%.7z" %1
SET archiveslist=%archiveslist% "%arcname%.%z7zmethodName%.7z"
EXIT /B
)
:leaveSmallestOnlyTestsmallest
(
    REM takes list of archive files as arguments
    REM compares them by size
    REM and deletes bigger
    REM Then tests (%exe7z% t) smallest left over
    SET "smallest=%~1"
    CALL :GetSize smallestsize "%~1" || (ECHO Something wrong, terminating deletion.& EXIT /B)
)
:leaveSmallest_next
(
    REM first check if there are any concurrents left
    IF "%~2" EQU "" (
	ECHO Finished deleting bigger archives, testing last one left.
	START "Testing %smallest%" /BELOWNORMAL /B /WAIT %exe7z% t -- "%smallest%"
	EXIT /B
    )
    CALL :GetSize concurrentsize "%~2" || (ECHO Something wrong, terminating deletion.& EXIT /B)
    SHIFT
)
IF %smallestsize% GTR %concurrentsize% (
    ECHO Deleting "%smallest%" because it is bigger than "%~1"
    DEL "%smallest%"
    SET "smallest=%~1"
    SET "smallestsize=%concurrentsize%"
) ELSE (
    ECHO Deleting "%~1" because it is bigger than "%smallest%"
    DEL "%~1"
)
GOTO :leaveSmallest_next
:renameNoSuffix
(
    REN "%~1" *.
    REN "%~dpn1" "*%~x1"
    EXIT /B
)
:GetSize <varname> <path>
(
    SETLOCAL
    IF NOT EXIST "%~2" (ECHO File "%~2" not found.& EXIT /B 2)
    SET "size="
    FOR %%I IN ("%~2") DO (
	IF DEFINED size (ECHO Multiple files found for path "%~2".& EXIT /B 1)
	IF %%~zI LSS %minArcSize% (ECHO File "%~2" size is %%~zI bytes. Must be at least %minArcSize%.& EXIT /B 1)
	SET "size=%%~zI"
    )
    REM Check if file found and size is set
    IF NOT DEFINED size (ECHO File "%~2" size cannot be determined.& EXIT /B 2)
)
(
    ENDLOCAL
    SET "%~1=%size%"
    EXIT /B
)
