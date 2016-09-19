@REM coding:OEM

SET counter=%TEMP%\wsus-counter.txt
IF NOT "%~1"=="" (
    ECHO %~1 >"%counter%"
    EXIT /B
)

IF NOT EXIST "%counter%" EXIT /B 1

FOR /F "usebackq" %%I IN ("%counter%") DO (
    SET "count=%%~I"
    GOTO :read
)
ECHO Cannot read count from "%counter%">"%TEMP%\%~n0.log"
EXIT /B
:read

SET /A count-=1
IF %count% LSS 1 (
    DEL "%counter%"
    SCHTASKS /DELETE /TN run_wsusoffline_multiple_times
    EXIT /B
)

ECHO %count% >"%counter%"
SET UpdatePath=Distributives\Updates\Windows\wsusoffline\Update_With_Autoreboot.cmd

CALL :ConnectServer Srv0.office0.mobilmir || CALL CALL :ConnectServer Srv0 || CALL :ConnectServer 192.168.1.80

ECHO Update Server: \\%UpdateSrvr%

START "" /B /WAIT %comspec% /C "\\%UpdateSrvr%\%UpdatePath%" /instie10

SHUTDOWN /R /T 30

EXIT /B

:ConnectServer
    SET UpdateSrvr=%~1
    ECHO | NET USE \\%UpdateSrvr%\Distributives /USER:nobody
    IF NOT EXIST "\\%UpdateSrvr%\%UpdatePath%" EXIT /B 1
EXIT /B
