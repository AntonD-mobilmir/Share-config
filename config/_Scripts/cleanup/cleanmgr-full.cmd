@REM coding:CP866
IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)

rem cleanmgr.exe /sageset:65535

FOR %%A IN (C D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST "%%~A:\Windows.old\Users" CALL :MoveUsers "%%~A:\Windows.old"

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

START "mousemove while cleanmgr.exe running.ahk" /LOW /MIN %comspec% /C ""%~dp0..\FindAutoHotkeyExe.cmd" "%~dp0..\GUI\mousemove while cleanmgr.exe running.ahk""

cleanmgr.exe /sagerun:65535
EXIT /B

:MoveUsers
@SET "date=%~t1"
@SET "date=%date::=%"
@SET "date=%date:\=%"
@SET "date=%date:/=%"
(
    MOVE "%~1\Users" "%~dp1Users @ %~nx1 %date%"
EXIT /B
)
