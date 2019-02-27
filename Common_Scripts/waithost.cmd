@(REM coding:CP866
REM wait until specified host responds to pings, then exit
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
REM
REM This work by LogicDaemon is licensed under a Creative Commons Attribution 3.0 Unported License.
REM http://creativecommons.org/licenses/by/3.0/

SETLOCAL ENABLEEXTENSIONS
IF "%1"=="/?" GOTO help
SET "count=%~2"
IF NOT DEFINED count SET /A "count=900"
SET "host=%~1"
IF NOT DEFINED host FOR /F "usebackq tokens=3 delims= " %%I IN (`route print 0.0.0.0 ^| find "0.0.0.0"`) DO SET "host=%%~I"
)
:retry
(
IF %count% EQU 1 (
    ping -n 1 %host%
    EXIT /B
)

ping -n 1 %host% >nul || (
    ping 127.0.0.1 -n 2 -w 1000 >nul
    SET /A "count-=1"
    GOTO :retry
)
EXIT /B
)
:help
@(
    ECHO usage:
    ECHO %0 host [retries]
    ECHO 	host	IP or hostname of destination
    ECHO 	retries	maximum number of pings ^(15 by default^)
    ECHO .
    ECHO IF no answer received (ping ever returned with error) it pings host with ping defaults to show error message and stats
EXIT /B
)
