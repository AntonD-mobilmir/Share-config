@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    IF NOT EXIST "%~1" (
        START "" https://itmobilmirru.freshdesk.com/a/tickets/11998
        START "" https://itmobilmirru.freshdesk.com/a/tickets/12890
    )

    IF NOT EXIST "%~1_empty" (
        ECHO MOVE "%~1" "%~1_empty"
        MOVE "%~1" "%~1_empty" || EXIT /B
        ECHO MOVE "%~1_" "%~1"
        MOVE "%~1_" "%~1" || EXIT /B
    )

    ECHO Removing dirs from "%~1"
    RD /S /Q "%~1\AppData\Local\Comms" || EXIT /B
    RD /S /Q "%~1\AppData\Local\Packages" || EXIT /B
    RD /S /Q "%~1\AppData\Local\Publishers" || EXIT /B
    RD /S /Q "%~1\AppData\Local\ConnectedDevicesPlatform" || EXIT /B
    RD /S /Q "%~1\AppData\Local\Microsoft\Windows\UPPS" || EXIT /B
    
    ECHO Moving dirs from "%~1_empty":
    ECHO AppData\Local\Packages
    MOVE "%~1_empty\AppData\Local\Packages" "%~1\AppData\Local\Packages"
    ECHO AppData\Local\Publishers
    MOVE "%~1_empty\AppData\Local\Publishers" "%~1\AppData\Local\Publishers"
    ECHO AppData\Local\Microsoft\Windows\UPPS
    MOVE "%~1_empty\AppData\Local\Microsoft\Windows\UPPS" "%~1\AppData\Local\Microsoft\Windows\UPPS"
)
