@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)
CALL "%~dp0find_exe.cmd" exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" "c:\Arc\7-Zip\7z.exe"
CALL :InitRemembering

SET "Target=%~d0WindowsImageBackup"
IF EXIST "%~1" SET "Target=%~1"
)
(
FOR %%I IN ("\\Srv0\Distributives\Soft private use only\Disk- File- Tools\Defragmentation\Piriform Defraggler\dfsetup*.exe") DO CALL :RememberIfLatest dfinst "%%~I"

IF EXIST "%Target%\WindowsImageBackup" SET "Target=%Target%\WindowsImageBackup"
CALL :getdrive "%Target%"
)
(
%SystemRoot%\System32\COMPACT.exe /C /I /S:"%Target%" *.*
CALL "%~dp0CheckWinVer.cmd" 6.2
IF ERRORLEVEL 1 ( REM Windows 7 or below
    "%SystemRoot%\System32\Defrag.exe" %DefragDrive%
) ELSE ( REM Windows 8+
    "%SystemRoot%\System32\Defrag.exe" /O %DefragDrive%
)

EXIT /B
)
:getdrive
    SET "DefragDrive=%~d1"
EXIT /B
:InitRemembering
(
    SET "LatestDate=0000000000:00"
EXIT /B
)
:RememberIfLatest <varName> <path>
(
    SET "CurrentDate=%~t2"
)
(
@rem     01.12.2011 21:29, so reverse date to get correct comparison
    SET "CurrentDate=%CurrentDate:~6,4%%CurrentDate:~3,2%%CurrentDate:~0,2%%CurrentDate:~11%"
)
(
    IF "%CurrentDate%" GEQ "%LatestDate%" (
	SET "%~1=%~2"
	SET "LatestDate=%CurrentDate%"
    )
EXIT /B
)
