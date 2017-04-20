@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
CALL :Find7z || GOTO :EXITWITHERROR
IF NOT DEFINED destdir CALL "%ProgramData%\mobilmir.ru\_rarus_backup_get_files.cmd" || CALL "%SystemDrive%\Local_Scripts\_rarus_backup_get_files.cmd"
    SET "Switches7z=-mqs=on"
rem SET Switches7z=-m0=LZMA2:a=1:d22:fb=64
    SET "datem=%DATE:~-4,4%-%DATE:~-7,2%"
    SET "dated=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%"
    FOR /F "usebackq tokens=2 delims==" %%I IN (`FTYPE AutoHotkeyScript`) DO SET ahkexe=%%I
)
(
    IF NOT EXIST "%destdir%" GOTO :NODESTINATION
    SET "destfname=ShopBTS_%datem%.7z"
    SET "destdname=ShopBTS_%dated%.7z"
    (ECHO.) >"%rarusbackupflag%"
    (
    ECHO.
    ECHO %DATE% %TIME% Starting archiving of "%CD%"
    )>>"%rarusbackuplogfile%"
    CALL :Get1stToken ahkexe %ahkexe%
)
(
    %ahkexe% /ErrorStdOut "%~dp0backup_1S_RemoveOld.ahk" >>"%rarusbackuplogfile%" 2>&1
    REM Full archive monthly & differential daily
    IF EXIST "%destdir%\%destfname%" (
	REM differential archiving if archive dont exist
	IF NOT EXIST "%destdir%\%destdname%" (
	    ECHO %DATE% %TIME% Making differential archive
	    ECHO %DATE% %TIME% Making differential archive>>"%rarusbackuplogfile%"
	    %exe7z% a -r -slp -bd %Switches7z% -u- -up0q3z0!"%destdir%\%destdname%.tmp" -x!Backup -x!Exchange -x!NEW_STRU -x!SYSLOG -xr!*.rar -xr!*.7z -xr!*.LCK -xr!*.cdx -x!*.flag -- "%destdir%\%destfname%" *>>"%rarusbackuplogfile%" 2>&1
	    IF ERRORLEVEL 2 GOTO :EXITWITHERROR
	    REN "%destdir%\%destdname%.tmp" *.
	    DEL "%rarusbackupflag%"
	    %exe7z% t -bd -- "%destdir%\%destdname%" >>"%rarusbackuplogfile%" 2>&1
	    IF ERRORLEVEL 2 GOTO :EXITWITHERROR
	) ELSE (
	    ECHO %DATE% %TIME% "%destdir%\%destdname%" already exist
	    ECHO %DATE% %TIME% "%destdir%\%destdname%" already exist>>"%rarusbackuplogfile%"
	    GOTO :EXITWITHERROR
	)
    ) ELSE (
	ECHO %DATE% %TIME% Making full archive
	ECHO %DATE% %TIME% Making full archive>>"%rarusbackuplogfile%"
	%exe7z% a -r -slp -bd %Switches7z% -x!Exchange -x!NEW_STRU -xr!*.rar -xr!*.7z -xr!*.LCK -xr!*.cdx -x!*.flag -- "%destdir%\%destfname%.tmp" *>>"%rarusbackuplogfile%" 2>&1
	IF ERRORLEVEL 2 GOTO :EXITWITHERROR
	REN "%destdir%\%destfname%.tmp" *.
	DEL "%rarusbackupflag%"
	%exe7z% t -bd -- "%destdir%\%destfname%" >>"%rarusbackuplogfile%" 2>&1
	IF ERRORLEVEL 2 GOTO :EXITWITHERROR
    )

    DEL "%rarusbackupflag%"
)
EXIT /B %ExitErrorLevel%

:Find7z
    IF NOT DEFINED ProgramData SET "ProgramData=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
    CALL :GetDir configDir %DefaultsSource%
    CALL "%configDir%_Scripts\find7zexe.cmd" || CALL "%configDir%_Scripts\find_exe.cmd" exe7z "%configDir%..\Soft\PreInstalled\utils\7za.exe" || (
	ECHO [!!!] Could not find 7-Zip!>>"%rarusbackuplogfile%"
	EXIT /B 1
    )
EXIT /B

:NODESTINATION
(
    ECHO "%destdir%" does not exist
    ECHO "%destdir%" does not exist>>"%rarusbackuplogfile%"
)
:EXITWITHERROR
(
    DEL "%rarusbackupflag%"
    ECHO %DATE% %TIME% Backup process terminated
    ECHO %DATE% %TIME% Backup process terminated>>"%rarusbackuplogfile%"
    SET "ExitErrorLevel=1"
EXIT /B
)
:Get1stToken
(
    SET %1="%~2"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
