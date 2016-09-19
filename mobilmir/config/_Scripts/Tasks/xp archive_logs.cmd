@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
CALL "%~dp0..\CheckWinVer.cmd" 6 && EXIT /B
SET WinVer=XP
CALL "%~dp0..\CheckWinVer.cmd" 5.1 || SET WinVer=2K

SET removeafter=0
SET schtasks=%SystemRoot%\System32\schtasks.exe
IF NOT EXIST "%schtasks%" (
  %exe7z% x "%~dp0schtasks.7z" -o"%TEMP%"
  SET schtasks=%TEMP%\schtasks.exe
  SET removeafter=1
)

IF NOT EXIST "%SystemRoot%\logs" MKDIR "%SystemRoot%\logs"

%exe7z% x "%~dp0Tasks.7z" "archive_logs_%WinVer%.job" -o"%SystemRoot%\Tasks"
"%schtasks%" /Change /RU SYSTEM /TN archive_logs_%WinVer%

IF "%removeafter%"=="1" DEL "%schtasks%"
