@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED rarusbackupflag CALL "%ProgramData%\mobilmir.ru\_rarus_backup_get_files.cmd" || CALL "%SystemDrive%\Local_Scripts\_rarus_backup_get_files.cmd"
IF NOT DEFINED rarusbackupflag SET "rarusbackupflag=%TEMP%\Rarus\running.flag"
SET "destdir=%TEMP%\Rarus"
SET "Switches7z=-mqs=on -mx=2"
CALL :Find7z || GOTO :EXITWITHERROR
)
ECHO. >"%rarusbackupflag%"
SET destfname=rarus-backup-%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%.7z

ECHO Запуск архивации
PUSHD d:\1S\Rarus\ShopBTS || GOTO :EXITWITHERROR
IF NOT EXIST "%destdir%" MKDIR "%destdir%"
%exe7z% a -r %Switches7z% -x!Exchange -x!ExtForms -x!Archive -x!NEW_STRU -xr!*.rar -xr!*.7z -xr!*.LCK -xr!*.cdx -x!*.flag "%destdir%\%destfname%" * || IF ERRORLEVEL 2 GOTO :EXITWITHERROR
%exe7z% t "%destdir%\%destfname%" || IF ERRORLEVEL 2 GOTO :EXITWITHERROR
POPD
PAUSE
START "" "%windir%\System32\explorer.exe" /select,"%destdir%\%destfname%"
EXIT /B

:Find7z
    IF NOT DEFINED ProgramData SET "ProgramData=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
    CALL :GetDir configDir %DefaultsSource%
    CALL "%configDir%_Scripts\find7zexe.cmd" || CALL "%configDir%_Scripts\find_exe.cmd" exe7z "%configDir%..\Soft\PreInstalled\utils\7za.exe" || (
	ECHO [!!!] Could not find 7-Zip!>>"%rarusbackuplogfile%"
	EXIT /B 1
    )
EXIT /B

:GetDir
    SET "%~1=%~dp2"
EXIT /B

:EXITWITHERROR
DEL "%rarusbackupflag%" & ECHO  & PAUSE & EXIT /B
