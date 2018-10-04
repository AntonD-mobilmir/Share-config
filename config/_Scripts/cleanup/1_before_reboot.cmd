@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

%SystemRoot%\System32\fltmc.exe >nul 2>&1 || (ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B)
IF DEFINED PROCESSOR_ARCHITEW6432 "%SystemRoot%\SysNative\cmd.exe" /C "%0 %*" & EXIT /B

SETLOCAL ENABLEEXTENSIONS

    REM /O switch does not work on Windows 7 and below
    CALL "%~dp0..\CheckWinVer.cmd" 6.2
    IF ERRORLEVEL 1 (
	START "Defragging %SystemDrive%" /MIN /I /LOW "%SystemRoot%\System32\Defrag.exe" %SystemDrive% /U /V
    ) ELSE START "Defragging %SystemDrive%" /MIN /I /LOW "%SystemRoot%\System32\Defrag.exe" %SystemDrive% /O /U /V
    
    ECHO DISM /Cleanup-image
    CALL "%~dp0dism_StartComponentCleanup.cmd"
    
    ECHO CleanMgr
    CALL "%~dp0cleanmgr-full.cmd"
    
    ECHO BleachBit
    START "BleachBit" /WAIT /MIN %comspec% /C "%~dp0BleachBit-auto.cmd" /ProfileOnSystemDrive

    ECHO Removing Sun JRE Local Distributive
    RD /S /Q "%APPDATA%\..\LocalLow\Sun"

    CALL "%~dp0..\CheckWinVer.cmd" 6 && (
	rem http://social.msdn.microsoft.com/Forums/en-US/56dc454e-268b-4ce0-8628-699a6befe457/how-to-delete-oversized-tops-file?forum=windowstransactionsprogramming
	rem :ShowTransactions
	rem fsutil resource info %SystemDrive%\
	rem ECHO Удалять журнал транзакций можно, только если сейчас нет активных транзакций.
	rem SET /P "continue=Удалить журнал транзакций? [пусто = снова посмотреть список транзакций, остальное = да; для отмены, закройте окно]"
	rem IF NOT DEFINED continue GOTO :ShowTransactions
	"%SystemRoot%\System32\fsutil.exe" resource setautoreset true %SystemDrive%\
    )
    echo y | "%SystemRoot%\System32\chkdsk.exe" %SystemDrive% /f /x
    
    REM Удаление БД Offline-файлов https://support.microsoft.com/en-us/help/942974/
    %SystemRoot%\System32\REG.exe ADD "HKLM\System\CurrentControlSet\Services\CSC\Parameters" /v FormatDatabase /t REG_DWORD /d 1 /f 

    IF NOT "%reboot%"=="0" (
	"%SystemRoot%\System32\shutdown.exe" /r /t 300
	ECHO Enter --- отмена перезагрузки.
	PAUSE >NUL
	"%SystemRoot%\System32\shutdown.exe" /a
    )
    
    EXIT /B
)
