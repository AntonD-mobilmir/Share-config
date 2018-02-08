@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS
ECHO OFF
:wait
    rem 7zG.exe                      10376 Console                    1  1ÿ873ÿ944 K
    @FOR /F "usebackq tokens=1" %%A IN (`TASKLIST /NH /FI "IMAGENAME eq %~1"`) DO @(
	IF ERRORLEVEL 1 EXIT /B
	IF /I "%%~A"=="%~1" ( PING -n 3 127.0.0.1 >NUL & GOTO :wait )
    )
    %2 %3 %4 %5 %6 %7 %8 %9
)
