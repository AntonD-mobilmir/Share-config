@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

CALL "%~dp0gam.cmd" info user %1 noaliases nolicenses noschemas > "%TEMP%\usergroups.txt"

FOR /F "usebackq delims=[] tokens=1" %%A IN (`FIND /i /n "Groups:" "%TEMP%\usergroups.txt"`) DO (
    SET "skip=%%~A"
)
)
:exitGroupsSkipFor

FOR /F "usebackq skip=%skip% delims=<> tokens=2" %%A IN ("%TEMP%\usergroups.txt") DO CALL "%~dp0gam.cmd" update group "%%~A" remove user %1
