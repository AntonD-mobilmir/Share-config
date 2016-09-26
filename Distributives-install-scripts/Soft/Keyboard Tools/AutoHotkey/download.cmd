@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

SET fname=ahk-install.exe
SET url=http://ahkscript.org/download/ahk-install.exe

IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp\ if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

IF NOT EXIST "%workdir%" MKDIR "%workdir%"

c:\SysUtils\curl.exe -k -R -L -o "%workdir%%fname%" -z "%workdir%%fname%" -L %url% || EXIT /B
"c:\SysUtils\lbrisar\getver.exe" "%workdir%%fname%" > "%workdir%ver.txt"
FOR /F "usebackq tokens=1" %%I IN ("%workdir%ver.txt") DO SET "ver=%%I"
IF NOT "%ver:~0,2%"=="1." EXIT /B 1

SET "distfmask=AutoHotkey*_Install.exe"
SET "dstfname=AutoHotkey%ver%_Install.exe"
CALL :linkdst "%workdir%%fname%"

EXIT /B

:linkdst
(
    SET cleanup_action=CALL "%baseScripts%\mvold.cmd"
    CALL "%baseScripts%\DistCleanup.cmd" "%srcpath%%distfmask%" "%srcpath%%dstfname%"
rem     %SystemDrive%\SysUtils\xln.exe %1 "%srcpath%%dstfname%"||
    COPY /B /Y %1 "%srcpath%%dstfname%"
)
EXIT /B
