@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    SET AddtoS_UScripts=0
    CALL "%~dp0download.cmd" %*
    PUSHD 5.1-beta && (
        CALL "%~dp05.1-beta\download.cmd"
        POPD
    )
)
