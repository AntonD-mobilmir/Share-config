@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

    IF DEFINED PROCESSOR_ARCHITEW6432 IF NOT DEFINED SecondRun (
	SET "SecondRun=1"
	"%SystemRoot%\SysNative\cmd.exe" /C %0 %*
	EXIT /B
    )

    IF EXIST "%~1" (
	SET "DefragDrive=%~d1"
	IF EXIST "%~1\WindowsImageBackup" (
	    SET "Target=%~1\WindowsImageBackup"
	) ELSE SET "Target=%~1"
    ) ELSE IF EXIST "%~d0WindowsImageBackup" (
	SET "Target=%~d0WindowsImageBackup"
	SET "DefragDrive=%~d0"
    ) ELSE (
	ECHO Не найдена папка для сжатия
	PING 127.0.0.1 -n 5>NUL
	EXIT /B
    )

    CALL "%~dp0CheckWinVer.cmd" 6.2 && (
	REM win8+ supports /O switch
	SET "DefragOpt=/O"
	
	CALL "%~dp0CheckWinVer.cmd" 6.4
	IF ERRORLEVEL 1 (
	    rem win8+ but not win10. Does not support compressed images.
	    SET "Target="
	) ELSE (
	    rem win10+
	    SET "CompactOpt=/EXE:LZX"
	)
    )
)
(
IF DEFINED Target START "Compacting %Target%" /B /WAIT /LOW %SystemRoot%\System32\COMPACT.exe /C %CompactOpt% /I /S:"%Target%" *.*
IF DEFINED DefragDrive START "Defrag" /B /WAIT /LOW "%SystemRoot%\System32\Defrag.exe" %DefragOpt% %DefragDrive%

EXIT /B
)
