@REM coding:CP866
@ECHO OFF
REM 7z-am main file
REM 
REM Theese scripts
REM run 7z with different arguments to gain maximum compression,
REM then compare results'size, deleting all but one smallest,
REM and test the last one at end.
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
REM This script is licensed under LGPL

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET srcpath=%~dp0

REM Setting defaults for all non-set vars
REM   compression parameters and methods defaults
CALL "%~dp07z_get_switches.cmd"

REM   other parameters
IF NOT DEFINED leaveSmallestOnly SET leaveSmallestOnly=1
IF NOT DEFINED deleteAfter SET deleteAfter=0
IF NOT DEFINED leastNoSuffix SET leastNoSuffix=0
IF NOT DEFINED Run7ZipGUI SET Run7ZipGUI=0

:readSwitches
SET curSwitch=%~1
REM -- - stop switches processing
IF "%curSwitch:~0,2%" EQU "--" (
  SHIFT
  GOTO :next
)
REM if first symbol is - or / then this is switch
SET FlagChar=%curSwitch:~0,1%
SET curSwitch=%curSwitch:~1%
IF "%FlagChar%" EQU "/" GOTO :processSwitch
IF "%FlagChar%" EQU "-" GOTO :processSwitch
REM else this is pathname
GOTO :next

:processSwitch
SET switchMeaning=1
REM invertor-modificator ("NO") processing
IF "%curSwitch:~0,2%" EQU "NO" (
  SET switchMeaning=0
  REM without comma, :~ returns till end of string
  SET curSwitch=%curSwitch:~2%
)

IF "%curSwitch:~0,1%" EQU "N" (
  SET switchMeaning=0
  SET curSwitch=%curSwitch:~1%
)

REM list and check 7zusedeflt* variables and change them if argument is appropriate
FOR /F "usebackq delims== tokens=1" %%I IN (`set z7zusedeflt`) DO (
  IF /I "z7zusedeflt%curSwitch%" EQU "%%I" (
    SET z7zusedeflt%curSwitch%=%switchMeaning%
    SHIFT
    GOTO :readSwitches
  )
)

GOTO :cmdswitch_%curSwitch%
GOTO :notknownswitch

:cmdswitch_LEAVEALL
:cmdswitch_LA
    REM simple inverse
    SET /A leaveSmallestOnly=1-%switchMeaning%
GOTO :cmdswitchok

:cmdswitch_DELETEAFTER
:cmdswitch_DA
  SET /A deleteAfter=%switchMeaning%
GOTO :cmdswitchok

:cmdswitch_LEASTNOSUFFIX
:cmdswitch_LNS
  SET /A leastNoSuffix=%switchMeaning%
GOTO :cmdswitchok

:cmdswitch_GUI
  SET /A Run7ZipGUI=%switchMeaning%
GOTO :cmdswitchok

:cmdswitchok
SHIFT
GOTO :readSwitches

:notknownswitch
REM if come here, switch is unknown. Treat it as pathname.

:next

SET exe7z="%srcpath%7z.exe"
SET guiexe7z="c:\Program Files\7-Zip\7zG.exe"
IF EXIST "%guiexe7z%" (
    IF %Run7ZipGUI%==1 SET exe7z=%guiexe7z%
    IF NOT EXIST %exe7z% SET exe7z=%guiexe7z%
)

PUSHD "%~1"
IF ERRORLEVEL 1 GOTO :nodirectory
REM when using braces () instead of gotos, script ceases to process args-with-braaces
  SET arcname=%CD%
  CALL :pack Directory
  POPD
  REM POPD does not change errorlevel
  IF NOT ERRORLEVEL 1 IF %deleteAfter%==1 RD /S /Q "%~1"
GOTO :endcycle
:nodirectory
  SET arcname=%~nx1
  SET source=%1
  CALL :pack File
  IF NOT ERRORLEVEL 1 IF NOT "%~x1"==".7z" IF %deleteAfter%==1 DEL "%~1"
:endcycle

SHIFT
REM test if there are more arguments. If there are, process them too (as paths)
IF NOT "%~1"=="" GOTO next
EXIT /B

:pack
SET archiveslist=
FOR /F "usebackq delims== tokens=1*" %%I IN (`set z7zusedeflt`) DO (
  IF /I "%%J" EQU "1" (
    CALL :getMethod %%I
    CALL :pack%1
  )
)
IF %leaveSmallestOnly%==1 CALL :leaveSmallestOnlyTestLeast %archiveslist%
IF %leastNoSuffix%==1 CALL :renameNoSuffix %least%
EXIT /B

:getMethod
SET z7zmethodName=%1
REM without comma, :~ returns till end of string
SET z7zmethodName=%z7zmethodName:~11%
FOR /F "usebackq delims== tokens=1*" %%I IN (`set z7zSwitches%z7zmethodName%`) DO (SET z7zSwitches=%%J & EXIT /b %ERRORLEVEL%)

:packDirectory
ECHO %exe7z% a -r %z7zSwitches% "%arcname%.%z7zmethodName%.7z"
start "Compressing [%z7zmethodName%] to %arcname%.%z7zmethodName%.7z" /B /WAIT %exe7z% a -r %z7zSwitches% "%arcname%.%z7zmethodName%.7z"
SET archiveslist=%archiveslist% "%arcname%.%z7zmethodName%.7z"
EXIT /B

:packFile
ECHO %exe7z% a %z7zSwitches% "%arcname%.%z7zmethodName%.7z" %source%
start "Compressing [%z7zmethodName%] to %arcname%.%z7zmethodName%.7z" /B /WAIT %exe7z% a %z7zSwitches% "%arcname%.%z7zmethodName%.7z" %source%
SET archiveslist=%archiveslist% "%arcname%.%z7zmethodName%.7z"
EXIT /B

:leaveSmallestOnlyTestLeast
REM takes list of archive files as arguments
REM compares them by size
REM and deletes bigger
REM Then tests (%exe7z% t) least left over
SET least=%1
SET leastsize=
FOR %%I IN (%least%) DO SET leastsize=%%~zI
REM Check if file found and size is set
IF "%leastsize%" EQU "0" (ECHO File %least% size is %leastsize% bytes. Failed to delete bigger. & EXIT /b 1)
IF "%leastsize%" EQU "" (ECHO File %least% not found. Failed to delete bigger. & EXIT /b 1)
:leaveSmallest_next
SHIFT
REM first check if there are any concurrents left
IF "%~1" EQU "" (
  ECHO No more files, finished deleting bigger
  %exe7z% t %least%
  EXIT /B
)
SET concurrentsize=
FOR %%I IN (%1) DO SET concurrentsize=%%~zI
IF "%concurrentsize%" EQU "0" (ECHO File %least% size is %leastsize% bytes. Terminating delete bigger. & EXIT /b 1)
IF "%concurrentsize%" EQU "" (ECHO File %least% not found. Terminating delete bigger. & EXIT /b 1)

IF /I %leastsize% GTR %concurrentsize% (
  ECHO Deleting %least% because it is bigger than %1
  DEL %least%
  SET least=%1
  SET leastsize=%concurrentsize%
) ELSE (
  ECHO Deleting %1 because it is bigger than %least%
  DEL %1
)
GOTO :leaveSmallest_next

:renameNoSuffix
REN %1 *.
REN "%~dpn1" *.7z
EXIT /B
