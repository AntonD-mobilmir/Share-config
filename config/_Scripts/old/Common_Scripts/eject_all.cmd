@(REM coding:OEM
ECHO OFF
REM Closes handles, syncs, then eject, then Safely Removes mounts
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
REM
REM This work by LogicDaemon is licensed under a Creative Commons Attribution 3.0 Unported License.
REM http://creativecommons.org/licenses/by/3.0/

SETLOCAL ENABLEEXTENSIONS DISABLEDELAYEDEXPANSION
IF EXIST "%ProgramData%\mobilmir.ru\eject_mountpoints.list" (
    SET MountpointRulesFile=%ProgramData%\mobilmir.ru\eject_mountpoints.list
    SET MountpointRulesSkipLines=
) ELSE (
    SET "MountpointRulesFile=%~f0"
    FOR /F "usebackq tokens=1 delims=[]" %%I IN (`%SystemRoot%\System32\find.exe /n "-!!! drive letter list-" "%~f0"`) DO SET "MountpointRulesSkipLines=skip=%%I"
)
)

:DontUseBuiltinList
IF EXIST "%ProgramFiles%\TrueCrypt\TrueCrypt.exe" "%ProgramFiles%\TrueCrypt\TrueCrypt.exe" /d /q

sync
SET ErrOccur=0

REM todo:	mountpoints with spaces won't work, if they're not quoted.
REM 		to avoid, get %* from output, and then parse it.
REM 		If 1-st arg isn't Volume, then pick whole string as mountpoint name
FOR /F "usebackq skip=9 tokens=1,3" %%A IN (`echo list volume ^| diskpart`) DO CALL :CheckVolOrDriveLetter %%A %%B

IF "%ErrOccur%"=="1" PAUSE

EXIT /B

:CheckVolOrDriveLetter
    IF %2.==. (
	SET Vol=%1
	GOTO :SkipLetterChecking
    )
    
    SET Vol=%2:
    
    rem check if this is Label, not Ltr (one char)
    IF NOT "%Vol%"=="%Vol:~0,1%:" EXIT /B
    
    :SkipLetterChecking

    SET doEject=
    SET doRemoveDrive=
    SET doKill=
    FOR /F "usebackq %MountpointRulesSkipLines% tokens=1,2,3,4,*" %%I IN ("%MountpointRulesFile%") DO (
	IF "%%I"=="" GOTO :exitfor
	IF /I "%%I"=="%Vol%" (
	    ECHO Ruleline for %Vol% found: Eject=%%J RemoveDrive=%%K Kill=%%L CustomCommand=%%M
	    SET doEject=%%J
	    SET doRemoveDrive=%%K
	    SET doKill=%%L
	    SET CustomCommand=%%M
	    GOTO :foundRules
	)
    )
    ECHO Ruleline for %Vol% not found. Using defaults.
    :foundRules

    IF DEFINED CustomCommand IF EXIST "%CustomCommand%" "%CustomCommand%"
    CALL :ExecuteAction %Vol% "CALL KillTasksWithFilesIn.cmd" "" %doKill%
    CALL :ExecuteAction %Vol% eject.exe "" %doEject%
    CALL :ExecuteAction %Vol% removedrive.exe "-b -i" %doRemoveDrive%
    REM removedrive -h really causes halt!
    REM better run handle.exe %Vol%

EXIT /B

:ExecuteAction <drive> <"command/action"> <"arguments"> <actionletter>
REM arguments:
REM %1 - drive
REM %2 - command/action with arguments before driveletter
REM %3 - "double-quoted" command arguments after driveletter
REM %4 - action check (d, n, f or nothing), look explanation below, before defaults list
GOTO switch_%4
:switch_
:switch_d
IF NOT EXIST %1 EXIT /B

:switch_f
fsutil volume dismount %%1
ECHO Executing %~2 %1 %~3
%~2 %1 %~3
IF ERRORLEVEL 1 SET /A ErrOccur+=1

:switch_n
EXIT /B

REM List of drive letters to check follows.
REM
REM letters not in list processed as defaults (kill, eject, then removedrive, if it's still exist)
REM empty line (or end of file) is endlist-marker
REM 
REM list-format:
REM driveletter doEject doRemoveDrive doKill custom_command
REM
REM doEject doRemoveDrive and doKill are either f,n,d or nothing
REM d and nothing mean Default: check existence before action (eject, then removedrive)
REM n mean Never
REM f mean Force (always) despite letter existence/accessibility
REM
REM -!!! drive letter list- this is list start marker
A: n n
B: n n
C: n n n
C:\WINDOWS\SwapSpace n n n
C:\WINDOWS\SwapSpace\ n n n
D: d n n
E: d n
I: d n
J: d n
K: d n
L: d n
R: n n n
S: n n n
W: n n n
