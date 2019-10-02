@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    FOR /F "usebackq skip=3 tokens=1" %%A IN (`NET VIEW`) DO (
        IF EXIST "%%~A\c$\ProgramData\mobilmir.ru\_get_SoftUpdateScripts_source.cmd" @(
            ECHO %%~A
            COPY /Y /D /B "%~dp0dist\_get_SoftUpdateScripts_source.cmd" "%%~A\c$\ProgramData\mobilmir.ru\_get_SoftUpdateScripts_source.cmd"
            COPY /Y /D /B "%~dp0dist\SoftUpdateScripts_source.txt" "%%~A\c$\ProgramData\mobilmir.ru\SoftUpdateScripts_source.txt"
        )
    )
)
