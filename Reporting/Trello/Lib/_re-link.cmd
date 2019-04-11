@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    PUSHD "%~dp0" || EXIT /B
    FOR %%A IN (*.ahk) DO IF EXIST "%~dp0..\..\..\..\Backups\profiles$\Share\config\_Scripts\Lib\%%~nxA" (
        DEL "%%~A"
        MKLINK "%%~A" "%~dp0..\..\..\..\Backups\profiles$\Share\config\_Scripts\Lib\%%~nxA"
    )
    POPD
)
