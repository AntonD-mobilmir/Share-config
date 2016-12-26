@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
CALL "%~dp0PlugIns\wcx\Total7zip\7z_get_switches.cmd"

SET "dstDir=x:\Distributives\Soft\PreInstalled\manual"
SET "tmpDir=%TEMP%\PreInstalled-tc-new"
SET "bakDir=%TEMP%\PreInstalled-tc-backup"
SET "arcname=TotalCommander.7z"
SET "arcname64bit=TotalCommander.64bit.7z"
SET "arcnamePlugins=TotalCommander.Plugins.7z"
SET "arcnamePlugins64bit=TotalCommander.Plugins64bit.7z"
SET "arcnameConfig=TotalCommander.config.7z"
)
PUSHD "%srcpath%" && (
MKDIR "%tmpDir%"


rem 0. dont pack -  %~n0.exclude-list.txt

rem 1. %~n0.config-list.txt without 0
"%~dp0AutoHotkey.exe" "%~dp0CleanupNotepad2Ini.ahk" "%~dp0notepad2.ini"
"%~dp0PlugIns\wcx\Total7zip\7zg.exe" u -uq0 -r %z7zswitchesLZMA2BCJ2% -x@"%~n0.exclude-list.txt" -i@"%~n0.config-list.txt" -- "%tmpDir%\%arcnameConfig%"
MOVE /Y "%~dp0notepad2.ini.bak" "%~dp0notepad2.ini"

rem 2. %~n0.plugins64bit-list.txt without 0,1
"%~dp0PlugIns\wcx\Total7zip\7zg.exe" u -uq0 -r %z7zswitchesLZMA2BCJ2% -x@"%~n0.exclude-list.txt" -x@"%~n0.config-list.txt" -i@"%~n0.plugins64bit-list.txt" -- "%tmpDir%\%arcnamePlugins64bit%"

rem 3. %~n0.plugins-list.txt without 0,1,2
"%~dp0PlugIns\wcx\Total7zip\7zg.exe" u -uq0 -r %z7zswitchesLZMA2BCJ2% -x@"%~n0.exclude-list.txt" -x@"%~n0.config-list.txt" -x@"%~n0.plugins64bit-list.txt" -i@"%~n0.plugins-list.txt" -- "%tmpDir%\%arcnamePlugins%"

rem 4. %~n0.64bit-list.txt without 0,1,2,3
"%~dp0PlugIns\wcx\Total7zip\7zg.exe" u -uq0 -r %z7zswitchesLZMA2BCJ2% -x@"%~n0.exclude-list.txt" -x@"%~n0.config-list.txt" -x@"%~n0.plugins64bit-list.txt" -x@"%~n0.plugins-list.txt" -i@"%~n0.64bit-list.txt" -- "%tmpDir%\%arcname64bit%"

rem 5. everything else without all previous
"%~dp0PlugIns\wcx\Total7zip\7zg.exe" u -uq0 -r %z7zswitchesLZMA2BCJ2% -x@"%~n0.exclude-list.txt" -x@"%~n0.config-list.txt" -x@"%~n0.plugins64bit-list.txt" -x@"%~n0.plugins-list.txt" -x@"%~n0.64bit-list.txt" -- "%tmpDir%\%arcname%"

MKDIR "%bakDir%"
FC "%tmpDir%\%arcnameConfig%" "%dstDir%\%arcnameConfig%" > NUL || (MOVE /Y "%dstDir%\%arcnameConfig%" "%bakDir%\%arcnameConfig%" & MOVE "%tmpDir%\%arcnameConfig%" "%dstDir%\%arcnameConfig%")
FC "%tmpDir%\%arcname%" "%dstDir%\%arcname%" > NUL || (MOVE /Y "%dstDir%\%arcname%" "%bakDir%\%arcname%" & MOVE "%tmpDir%\%arcname%" "%dstDir%\%arcname%")
FC "%tmpDir%\%arcname64bit%" "%dstDir%\%arcname64bit%" > NUL || (MOVE /Y "%dstDir%\%arcname64bit%" "%bakDir%\%arcname64bit%" & MOVE "%tmpDir%\%arcname64bit%" "%dstDir%\%arcname64bit%")
FC "%tmpDir%\%arcnamePlugins%" "%dstDir%\%arcnamePlugins%" > NUL || (MOVE /Y "%dstDir%\%arcnamePlugins%" "%bakDir%\%arcnamePlugins%" & MOVE "%tmpDir%\%arcnamePlugins%" "%dstDir%\%arcnamePlugins%")
FC "%tmpDir%\%arcnamePlugins64bit%" "%dstDir%\%arcnamePlugins64bit%" > NUL || (MOVE /Y "%dstDir%\%arcnamePlugins64bit%" "%bakDir%\%arcnamePlugins64bit%" & MOVE "%tmpDir%\%arcnamePlugins64bit%" "%dstDir%\%arcnamePlugins64bit%")
RD "%tmpDir%"
)
