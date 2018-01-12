@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

:runmsiexec
%*
IF ERRORLEVEL 1618 IF NOT ERRORLEVEL 1619 @(ECHO %DATE% %TIME% Выполняется другая установка, ожидание 30 секунд перед повтором & PING 127.0.0.1 -n 30 >NUL & GOTO :runmsiexec )
IF ERRORLEVEL 3010 IF NOT ERRORLEVEL 3011 EXIT /B 0 & rem restart required
EXIT /B
)
