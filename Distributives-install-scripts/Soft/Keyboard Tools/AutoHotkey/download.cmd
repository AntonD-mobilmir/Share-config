@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "url=https://autohotkey.com/download/ahk-install.exe"
SET "fname=ahk-install.exe"
IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"
)
CALL "%baseScripts%\_GetWorkPaths.cmd"
(
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp\ if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"
IF NOT EXIST "%workdir%" MKDIR "%workdir%"
c:\SysUtils\curl.exe -k -R -L -o "%workdir%%fname%" -z "%workdir%%fname%" -L %url% || EXIT /B
c:\SysUtils\lbrisar\getver.exe "%workdir%%fname%" > "%workdir%ver.txt"
FOR /F "usebackq tokens=1" %%I IN ("%workdir%ver.txt") DO SET "ver=%%I"
)
(
IF NOT "%ver:~0,2%"=="1." EXIT /B 1

SET "distfmask=AutoHotkey_*_setup.exe"
SET "dstfname=AutoHotkey_%ver%_setup.exe"
CALL :linkdst "%workdir%%fname%"

EXIT /B
)
:linkdst
(
    SET cleanup_action=CALL "%baseScripts%\mvold.cmd"
    CALL "%baseScripts%\DistCleanup.cmd" "%srcpath%%distfmask%" "%srcpath%%dstfname%"
rem     %SystemDrive%\SysUtils\xln.exe %1 "%srcpath%%dstfname%"||
    COPY /B /Y %1 "%srcpath%%dstfname%"
EXIT /B
)
