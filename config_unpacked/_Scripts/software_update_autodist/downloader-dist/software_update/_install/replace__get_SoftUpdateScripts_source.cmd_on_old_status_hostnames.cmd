@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    FOR /D %%A IN ("%~dp0..\old\status\*.*") DO (
        IF EXIST "\\%%~nxA\c$\ProgramData\mobilmir.ru\_get_SoftUpdateScripts_source.cmd" @(
            ECHO %%~nxA
            COPY /Y /D /B "%~dp0dist\_get_SoftUpdateScripts_source.cmd" "\\%%~nxA\c$\ProgramData\mobilmir.ru\_get_SoftUpdateScripts_source.cmd"
            COPY /Y /D /B "%~dp0dist\SoftUpdateScripts_source.txt" "\\%%~nxA\c$\ProgramData\mobilmir.ru\SoftUpdateScripts_source.txt"
        )
    )
)
