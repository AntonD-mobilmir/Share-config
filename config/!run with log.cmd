@(REM coding:CP866
ECHO OFF
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
%SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )
SETLOCAL ENABLEEXTENSIONS
    IF "%~1"=="" GOTO :selectRunScript
    CALL :DefineLogName
)
(
    ENDLOCAL
    ECHO ON
    %* >"%logname%" 2>&1
    EXIT /B
)

:selectRunScript
(
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
IF DEFINED script%num% (
    SET "runscript=!script%num%!"
) ELSE SET "runscript=%num%"
CALL :DefineLogName "%runscript%"
(
    ENDLOCAL
    ECHO ON
    "%runscript%" >"%logname%" 2>&1
    EXIT /B
)
:DefineLogName <path>
    SET "logname=%TEMP%\%~nx1.log"
(
    START "%logname%" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\PreInstalled\utils\tail.exe" -v -F -c +0 "%logname%"
EXIT /B
)
