:next <removing %1>
@(
REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
    %SystemRoot%\System32\takeown.exe /R /SKIPSL /D Y /F %1
    RD /S /Q %1
    IF NOT "%~2"=="" (
        SHIFT
        GOTO :next
    )
)
