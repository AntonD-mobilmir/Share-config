@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

SET "unattended=1"
FOR /F "usebackq tokens=1,2,3 eol=# delims=	" %%A IN ("%~1") DO CALL "%~dp0create retail dept mailbox.cmd" "%%~A" "%%~B" "%%~C"
)
