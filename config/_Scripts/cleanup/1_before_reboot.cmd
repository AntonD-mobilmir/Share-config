@REM coding:OEM
@ECHO OFF
IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)

REM /O switch does not work on Windows 7 and below
CALL "%~dp0..\CheckWinVer.cmd" 6.2
IF ERRORLEVEL 1 (
    START "Defragging %SystemDrive%" /MIN /I /LOW "%SystemRoot%\System32\Defrag.exe" %SystemDrive% /U /V
) ELSE START "Defragging %SystemDrive%" /MIN /I /LOW "%SystemRoot%\System32\Defrag.exe" %SystemDrive% /O /U /V

rem "%SystemRoot%\System32\DISM.exe" /Online /Cleanup-image /scanhealth
rem "%SystemRoot%\System32\DISM.exe" /Online /Cleanup-image /RestoreHealth

ECHO "%SystemRoot%\System32\DISM.exe" /Online /Cleanup-image /spsuperseded /hidesp
"%SystemRoot%\System32\DISM.exe" /Online /Cleanup-image /spsuperseded /hidesp

ECHO "%SystemRoot%\System32\DISM.exe" /Online /Cleanup-Image /StartComponentCleanup /ResetBase
"%SystemRoot%\System32\DISM.exe" /Online /Cleanup-Image /StartComponentCleanup /ResetBase

ECHO Running CleanMgr
CALL "%~dp0cleanmgr-full.cmd"

START "BleachBit" /WAIT %comspec% /C "%~dp0BleachBit-auto.cmd"

ECHO Removing Sun JRE Local Distributive
RD /S /Q "%APPDATA%\..\LocalLow\Sun"

CALL "%~dp0..\CheckWinVer.cmd" 6 || GOTO :skipTransactonRemoval
rem http://social.msdn.microsoft.com/Forums/en-US/56dc454e-268b-4ce0-8628-699a6befe457/how-to-delete-oversized-tops-file?forum=windowstransactionsprogramming
:ShowTransactions
rem fsutil resource info %SystemDrive%\
rem ECHO Удалять журнал транзакций можно, только если сейчас нет активных транзакций.
rem SET /P continue=Удалить журнал транзакций? [1=да, пусто = снова посмотреть список транзакций]
rem IF "%continue%"=="" GOTO :ShowTransactions
rem IF "%continue%"=="1" (
    "%SystemRoot%\System32\fsutil.exe" resource setautoreset true %SystemDrive%\
rem )
:skipTransactonRemoval

echo y | "%SystemRoot%\System32\chkdsk.exe" %SystemDrive% /f /x

IF "%reboot%"=="0" GOTO :skipReboot

"%SystemRoot%\System32\shutdown.exe" /r /t 300
ECHO Enter --- отмена перезагрузки.
PAUSE >NUL
"%SystemRoot%\System32\shutdown.exe" /a

:skipReboot
