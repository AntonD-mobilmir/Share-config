@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
    SET "srcpath=%~dp0"
    SET "uninstallFirst=1"
    IF "%~1"=="/LeaveLast" (
	SET "uninstallFirst="
	SHIFT
    )
)
:uninstallLoop
SET "uninstallNext=%uninstallFirst%"
@(
    IF "%~1"=="" EXIT /B
    FOR /F "usebackq eol=# tokens=1,2*" %%A IN (%1) DO @(
	IF DEFINED uninstallNext (
	    ECHO Uninstalling %%B
	    CALL "%srcpath%run_msiexec.cmd" %SystemRoot%\System32\msiexec.exe /x {%%A} /qn /norestart
	) ELSE (
	    ECHO Skipping %%B
	    SET "uninstallNext=1"
	)
    )
    SHIFT
    GOTO :uninstallLoop
)
