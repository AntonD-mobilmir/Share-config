@(REM coding:CP866
rem Input:
rem srcpath --- mandatory
rem baseDistUpdateScripts
rem baseDistributives
rem baseWorkdir
rem baseLogsDir

rem Output:
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (with trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp\ if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or workdir)

REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.

IF NOT DEFINED srcpath EXIT /B 32767
SETLOCAL ENABLEDELAYEDEXPANSION
    CALL :checkFixBackslash srcpath "%srcpath%"
    IF DEFINED baseDistUpdateScripts SET srcpath=!srcpath:%baseDistUpdateScripts%\=%baseDistributives%\!
    IF DEFINED baseDistributives SET relpath=!srcpath:%baseDistributives%\=\!
    IF "!relpath!"=="!srcpath!" SET "relpath="
)
(
ENDLOCAL
    SET "srcpath=%srcpath%"
    SET "relpath=%relpath%"
)
(
    IF DEFINED relpath (
        IF NOT DEFINED workdir IF DEFINED baseWorkdir SET "workdir=%baseWorkdir%%relpath%"
        IF NOT DEFINED logsDir IF DEFINED baseLogsDir SET "logsDir=%baseLogsDir%%relpath%"
    )
    IF NOT DEFINED workdir SET "workdir=%srcpath%temp\"
)
(
    IF NOT DEFINED logsDir SET "logsDir=%workdir%"
EXIT /B
)
:checkFixBackslash <varname> <valuetocheckforbackslash> <0 if backslash should be removed, not added>
(
    SETLOCAL
    SET "tempvar=%~2"
)
IF "%~3"=="0" (
    IF "%tempvar:~-1%"=="\" SET tempvar=%tempvar:~0,-1%
) ELSE (
    IF NOT "%tempvar:~-1%"=="\" SET "tempvar=%tempvar%\"
)
(
    SET "%1=%tempvar%"
    ENDLOCAL
EXIT /B
)
