@REM coding:OEM
@ECHO OFF
:again
ping %1 -n 1
IF ERRORLEVEL 1 (
    ping 127.0.0.1 -n 2 >NUL
    GOTO :again
)
ECHO 
GOTO :again
