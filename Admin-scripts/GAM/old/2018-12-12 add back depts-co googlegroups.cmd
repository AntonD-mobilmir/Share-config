@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

REM Я поудалял всех получателей из depts*-co@status
CALL switchdomain.cmd "status.mobilmir.ru"
FOR %%A IN (1 2 3 4 5 6 7) DO CALL gam.cmd update group "depts%A-co" add user "depts-co@status.mobilmir.ru"
CALL gam.cmd update group "depts4-co@status.mobilmir.ru" add user "depts4-co_status-mobilmir-ru@googlegroups.com"

REM а также группу depts-co@mobilmir.ru, но вместо неё стоит создать depts-co@status.mobilmir.ru
CALL gam.cmd create group "depts-co@status.mobilmir.ru"
CALL gam.cmd update group "depts-co@status.mobilmir.ru" add user "depts-co_mobilmir-ru@googlegroups.com"
)
