@REM coding:OEM
@ECHO OFF
(
    SETLOCAL ENABLEEXTENSIONS
    SET "runscript=%~1"
    SET "logname=%TEMP%\%~nx1.log"
)
(
    START "%logname%" "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\tail.exe" -v -F -c +0 "%logname%"
    IF "%runscript%"=="" (
	CALL :selectRunScript
    ) ELSE (
	ENDLOCAL
	ECHO ON
	%* >"%logname%" 2>&1
	EXIT /B
    )
)

:selectRunScript
(
    SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
    SET /A n=1
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
    SET "runscript=%runscript%"
)
(
    ENDLOCAL
    ECHO ON
    %runscript% >"%logname%" 2>&1
    EXIT /B
)
