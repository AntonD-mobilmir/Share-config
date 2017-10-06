@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
)

ECHO %DATE% %TIME%>>groups-depts-co.txt
FOR /F "usebackq" %%I IN (`gam.cmd print groups`) DO CALL :CheckGroup %%I
EXIT /B 

:CheckGroup
SET "GroupName=%~1"
IF "%GroupName:~0,9%"=="depts-co-" CALL gam.cmd info group %GroupName:@status.mobilmir.ru=%>>groups-depts-co.txt
EXIT /B
