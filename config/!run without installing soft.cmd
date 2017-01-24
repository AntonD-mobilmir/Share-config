@(REM coding:CP866
ECHO OFF
SET "SkipInstallsKeepQueue=1"
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT "%~1"=="" (
	ECHO ON
	%*
	EXIT /B
    )

    SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
    SET /A "n=1"
    FOR %%I IN ("%~dp0_*.cmd") DO (
	ECHO !n!: %%~nxI
	SET "script!n!=%%~fI"
	SET /A n+=1
    )
    
    ECHO Какой скрипт запустить? ^(номер или полный путь^)
    SET /P "num=^> "
)
(
    IF DEFINED script%num% (
	SET "runscript=!script%num%!"
    ) ELSE SET "runscript=%num%"
)
(
    ENDLOCAL
    "%runscript%"
    EXIT /B
)
