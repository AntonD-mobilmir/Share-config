@REM coding:OEM
IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)

rem cleanmgr.exe /sageset:65535

CALL "%~dp0..\CheckWinVer.cmd" 10 && GOTO :Win10
CALL "%~dp0..\CheckWinVer.cmd" 6 && GOTO :WinVista
CALL "%~dp0..\CheckWinVer.cmd" 5 && GOTO :WinXP
EXIT /B 1

:Win10
CALL :RunCleanup "%~dp0cleanmgr_win10.reg"
EXIT /B

:WinVista
CALL :RunCleanup "%~dp0cleanmgr_win6.reg"
EXIT /B

:WinXP
CALL :RunCleanup "%~dp0cleanmgr_win5.reg"
EXIT /B

:RunCleanup <settings-file>
REG IMPORT "%~1"
cleanmgr.exe /sagerun:65535
EXIT /B
