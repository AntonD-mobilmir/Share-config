@REM coding:OEM

SETLOCAL ENABLEEXTENSIONS
CALL "%~dp0..\CheckWinVer.cmd" 6 && EXIT /B

IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B


SET removeafter=0
SET schtasks=%SystemRoot%\System32\schtasks.exe
IF NOT EXIST "%schtasks%" (
  %exe7z% x -aos "%~dp0schtasks.7z" -o"%TEMP%"
  SET schtasks=%TEMP%\schtasks.exe
  SET removeafter=1
)

SET tscmd=%ALLUSERSAPPDATA%\Application Data\\mobilmir.ru\timesync.cmd

rem   ECHO Server Name [default: Srv0]
rem   SET /P ServerName=
IF "%ServerName%"=="" SET ServerName=Srv0

IF NOT DEFINED TaskUserName FOR /F "usebackq delims=\ tokens=2" %%I IN (`whoami`) DO SET TaskUserName=%%~I
IF NOT DEFINED TaskUserName SET TaskUserName=SYSTEM

ECHO @REM coding:OEM >"%tscmd%"
ECHO %%ComSpec%% /C waithost.cmd %ServerName% 300 >>"%tscmd%"
ECHO net.exe time \\%ServerName% /set /y >>"%tscmd%"

%exe7z% x -aoa "%~dp0Tasks.7z" "TimeSync.job" -o"%SystemRoot%\Tasks"
IF "%WinVer%"=="2K" GOTO :SkipSchtasks
  (ECHO Y)|"%schtasks%" /Delete /TN timesync
  (ECHO N)|"%schtasks%" /Create /TN timesync /RU "%TaskUserName%" /SC ONSTART /TR "%tscmd%"
  "%schtasks%" /CHANGE /TN timesync /RU "%TaskUserName%" /TR "%tscmd%"
:SkipSchtasks

IF "%removeafter%"=="1" DEL "%schtasks%"

