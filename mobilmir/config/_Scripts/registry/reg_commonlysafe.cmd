@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

SET TempDir=%TEMP%\Reg

IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
%exe7z% x -aoa "%~dp0reg.7z" -o"%TempDir%" || PAUSE

SET selfname=%~dpnx0
FOR /F "usebackq tokens=1 delims=[]" %%I IN (`find /n "REM -!!! Registry Files List -" "%selfname%"`) DO SET skiplines=%%I

PUSHD "%TempDir%" || (PAUSE & EXIT /B)

FOR /F "usebackq skip=%skiplines% eol=; tokens=*" %%A IN ("%selfname%") DO (
  FOR %%I IN ("%%A") DO REG IMPORT "%%~I"
)

POPD

RD /S /Q "%TempDir%" || PAUSE
ENDLOCAL

EXIT /B

REM -!!! Registry Files List -
for_all\*.reg
careful\CP_1251.reg
careful\ResetErrorCountersOnSuccess.reg

less_careful\networking\EnablePMTUBHDetect.reg
less_careful\networking\EnablePMTUDiscovery.reg
less_careful\networking\GlobalMaxTcpWindowSize.reg
less_careful\networking\SackOpts.reg
;less_careful\networking\Tcp1323Opts.reg
;less_careful\networking\TcpMaxDupAcks.reg

less_careful\IE_ErrorReportings_Disable.reg
less_careful\IE_NoUpdateCheck.reg
;less_careful\IoPageLockLimit_32768.reg
less_careful\M$Office2003_ErrorReportings_Disable.reg
less_careful\M$OfficeXP_ErrorReportings_Disable.reg
less_careful\Network_Time_Protocol_(NTP)_Server.reg
less_careful\WMPlayer_AutoUpdate_disable.reg
less_careful\WU_AutoRestart_Disable.reg

ui\Animation_Disable.reg
ui\BootTime_AutoCheck_CountDown.reg
