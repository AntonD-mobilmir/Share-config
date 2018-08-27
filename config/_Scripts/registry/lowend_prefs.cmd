@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS

    CALL "%~dp0..\find7zexe.cmd"
    SET "tmpo=%TEMP%\%~n0.%RANDOM%.tmp"
)
(
    %exe7z% x -o"%tmpo%" "%~dp0User.7z" "Win10 Disable Visual Effects for non-admin users.reg" "Windows 7 No UI Animations.reg"
    FOR %%A IN ("%tmpo%\*.reg") DO REG IMPORT "%%~A" && DEL "%%~A"
    RD /S /Q "%tmpo%"
)
