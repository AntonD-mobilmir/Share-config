@(REM coding:CP866
ECHO OFF
SET "SkipInstallsKeepQueue=1"
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
%SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )
    IF NOT "%~1"=="" (
	ECHO ON
	%*
	EXIT /B
    )

    SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
    SET /A "n=1"
    FOR %%I IN ("%~dp0_*.cmd") DO (
        SET "scriptName=%%~nI"
	IF "!scriptName:~0,1!"=="_" (
            SET "script!n!=%%~fI"
            ECHO !n!: %%~nxI
            SET /A "n+=1"
        )
    )
    
    ECHO Какой скрипт запустить? ^(номер или полный путь^)
    SET /P "num=^> "
)
(
    IF DEFINED script%num% (
	SET runscript="!script%num%!"
    ) ELSE SET "runscript=%num%"
)
(
    ENDLOCAL
    %comspec% /C "%runscript%"
    ECHO Скрипт "%runscript%" завершился.
    PING 127.0.0.1 -n 3 >NUL
    EXIT /B
)
