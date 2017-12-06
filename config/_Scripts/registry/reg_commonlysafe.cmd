@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

%SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )

SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    SET "TempDir=%TEMP%\%~n0"
    IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
)
(
    %exe7z% x -aoa "%~dp0System.7z" -o"%TempDir%" || PAUSE
    FOR /F "usebackq tokens=1 delims=[]" %%I IN (`find /n "REM -!!! Registry Files List -" "%~f0"`) DO SET skiplines=%%I
)
(
    PUSHD "%TempDir%" && (
	FOR /F "usebackq skip=%skiplines% eol=; tokens=*" %%A IN ("%~f0") DO FOR %%I IN ("%%A") DO %SystemRoot%\System32\REG.exe IMPORT "%%~I"
	POPD
    )
    RD /S /Q "%TempDir%"
    EXIT /B
)
REM -!!! Registry Files List -
for_all\*.reg
;careful\CP_1251.reg
;careful\ResetErrorCountersOnSuccess.reg

less_careful\networking\EnablePMTUBHDetect.reg
less_careful\networking\EnablePMTUDiscovery.reg
less_careful\networking\GlobalMaxTcpWindowSize.reg
;less_careful\networking\SackOpts.reg
;less_careful\networking\Tcp1323Opts.reg
;less_careful\networking\TcpMaxDupAcks.reg

less_careful\IE_ErrorReportings_Disable.reg
less_careful\IE_NoUpdateCheck.reg
;less_careful\IoPageLockLimit_32768.reg
;less_careful\M$Office2003_ErrorReportings_Disable.reg
;less_careful\M$OfficeXP_ErrorReportings_Disable.reg
;less_careful\Network_Time_Protocol_(NTP)_Server.reg
;less_careful\WMPlayer_AutoUpdate_disable.reg
;less_careful\WU_AutoRestart_Disable.reg

;ui\Animation_Disable.reg
;ui\BootTime_AutoCheck_CountDown.reg
