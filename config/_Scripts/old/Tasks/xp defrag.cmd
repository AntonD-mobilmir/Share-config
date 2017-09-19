@REM coding:OEM

IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
SETLOCAL ENABLEEXTENSIONS

SET removeafter=0
SET schtasks=%SystemRoot%\System32\schtasks.exe
IF NOT EXIST "%schtasks%" (
  %exe7z% x "%~dp0schtasks.7z" -o"%TEMP%"
  SET schtasks=%TEMP%\schtasks.exe
  SET removeafter=1
)

IF NOT DEFINED z7zoverwriteopt SET z7zoverwriteopt=-aoa
%exe7z% x %z7zoverwriteopt% -o"%SystemRoot%\Tasks" -- "%~dp0Tasks.7z" "defrag*.job"
FOR %%I IN ("%WinDir%\Tasks\defrag*.job") DO "%schtasks%" /Change /RU SYSTEM /TN "%%~nI"

IF "%removeafter%"=="1" DEL "%schtasks%"
