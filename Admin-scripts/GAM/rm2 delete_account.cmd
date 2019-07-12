@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    IF "%~1"=="" (
        ECHO Удаляет пользователя
        ECHO Использование:
        ECHO     %0 ^<email^>
        EXIT /B 10000
    )
    
    FOR /F "delims=@ tokens=1*" %%A IN ("%~1") DO (
        SET "emailid=%%~A"
        SET "domain=%%~B"
    )
)
(
    IF NOT "%emailid:~0,4%"=="-rm-" (
        ECHO Адрес учётной записи не начинается с "-rm-". Удаление должно выполняться по спецификации https://trello.com/b/Z2zouNv6/
        EXIT /B 10000
    )

    CALL "%~dp0switchdomain.cmd" "%domain%"
    CALL "%~dp0gam.cmd" delete user %1
EXIT /B
)
