@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    SET "domain=%~1"
    IF NOT DEFINED domain SET "domain=mobilmir.ru"
)
@(
    CALL "%~dp0switchdomain.cmd" %domain%
    CALL "%~dp0gam.cmd" print group-members > "groups %domain% %DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%.txt"
)
