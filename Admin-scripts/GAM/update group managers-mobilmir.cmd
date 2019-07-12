@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS
    rem gam create group <group email> [name <Group Name>] [description <Group Description>]
    CALL "%~dp0switchdomain.cmd" mobilmir.ru
    CALL "%~dp0gam.cmd" print group-members group managers>managers-list.csv
)
@(
    head -n 1 managers-list.csv
    rem FIND "@mobilmir.ru"",""MEMBER"",""USER""" managers-list.csv
    FIND "@mobilmir.ru,MEMBER,USER," managers-list.csv
) >managers-mobilmir.ru-list.csv
(
    PAUSE
    rem allmail|nomail|daily|digest
    CALL gam update group managers-mobilmir sync member nomail csv "managers-mobilmir.ru-list.csv:email"
    rem -- ERROR: 401: Domain cannot use Api, Groups service is not installed. - authError -- CALL gam update group managers-mobilmir description "Пользователи из managers@mobilmir.ru с почтой в @mobilmir.ru, обновлена %DATE% %TIME%"
)
