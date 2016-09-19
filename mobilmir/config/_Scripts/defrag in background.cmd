@REM coding:CP866
@REM by LogicDaemon <www.logicdaemon.ru>
@REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)

"%WinDir%\System32\defrag.exe" /C /M /X
