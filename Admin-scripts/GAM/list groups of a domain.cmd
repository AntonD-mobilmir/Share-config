@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    SET "today=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%"
)
(
    IF "%~1"=="" FOR %%A IN ("mobilmir.ru" "status.mobilmir.ru" "zel.mobilmir.ru") DO CALL :PrintDomainGroups "%%~A" >"groups %%~A %today%.txt"
EXIT /B
)
:PrintDomainGroups
@(
    CALL "%~dp0switchdomain.cmd" %1
    CALL "%~dp0gam.cmd" print group-members
EXIT /B
)
