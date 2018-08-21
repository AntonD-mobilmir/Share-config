@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    CALL "%~dp0PlugIns\wcx\Total7zip\7z_get_switches.cmd"
    IF EXIST "%~dp0PlugIns\wcx\Total7zip\7z.exe" (SET exe7z="%~dp0PlugIns\wcx\Total7zip\7z.exe") ELSE SET exe7z="%~dp0PlugIns\wcx\Total7zip\7zg.exe"

    SET "dstDir=x:\Distributives\Soft\PreInstalled\manual"
    SET "tmpDir=%TEMP%\PreInstalled-tc-new"
    SET "bakDir=%TEMP%\PreInstalled-tc-backup"

    PUSHD "%~dp0\PlugIns\wdx\TrID_Identifier\TrID" && (
	CALL update.cmd
	POPD
    )
)
PUSHD "%srcpath%" && (
MKDIR "%tmpDir%"


rem 0. dont pack -  %~n0.exclude-list.txt
SET excludes=-x@"%~n0.exclude.txt"

CALL :PackAddExcl DBs

"%~dp0AutoHotkey.exe" "%~dp0CleanupNotepad2Ini.ahk" "%~dp0notepad2.ini"
CALL :PackAddExcl config
MOVE /Y "%~dp0notepad2.ini.bak" "%~dp0notepad2.ini"

CALL :PackAddExcl plugins64bit

CALL :PackAddExcl plugins

CALL :PackAddExcl 64bit

CALL :PackAddExcl 32bit

rem new block to let %excludes% update
)
(
rem everything else without all previous
%exe7z% u -uq0 -r %z7zswitchesLZMA2BCJ2% %excludes% -- "%tmpDir%\TotalCommander.7z"

MKDIR "%bakDir%"
FOR %%A IN ("%tmpDir%\*.*") DO FC /B /LB1 /A "%%~A" "%dstDir%\%%~nxA" > NUL || (MOVE /Y "%dstDir%\%%~nxA" "%bakDir%\%%~nxA" & MOVE "%%~A" "%dstDir%\%%~nxA")
RD "%tmpDir%"
EXIT /B
)

:PackAddExcl <listName>
(
    %exe7z% u -uq0 -r %z7zswitchesLZMA2BCJ2% %excludes% -i@"%~n0.%~1.txt" -- "%tmpDir%\TotalCommander.%~1.7z"
    SET excludes=%excludes% -x@"%~n0.%~1.txt"
EXIT /B
)
