@REM coding:OEM

IF "%~1"=="-p" SET persistent=-p

FOR /F "usebackq tokens=4" %%I IN (`route print`) DO (
    CALL :CheckAddressAddRoute %%I && GOTO :ExitFor
)

:ExitFor
EXIT /B

:CheckAddressAddRoute
    SET gw=%1
    IF NOT "%gw:~0,12%"=="192.168.127." EXIT /B 1
    route %persistent% add 192.168.1.0 mask 255.255.255.0 %gw%
    route %persistent% add 192.168.2.0 mask 255.255.255.0 %gw%
    route %persistent% add 172.22.2.0 mask 255.255.255.0 %gw%
EXIT /B 0
