@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

IF NOT DEFINED logmsi SET "logmsi=%TEMP%\Adobe Reader Updates.log"
IF DEFINED MSITransformFile SET MSITransformSwitch=/t"%MSITransformFile%"
)
(
FOR %%I IN ("%srcpath%updates\*.msp") DO CALL :runMsiExec /update "%%~I" %MSITransformSwitch% /qn /norestart /l+* "%logmsi%"
FOR %%I IN ("%srcpath%updates\AdbeRdrSec*.msp") DO CALL :runMsiExec /update "%%~I" %MSITransformSwitch% /qn /norestart /l+* "%logmsi%"

CALL "%~dp0RemoveUnneededAutorunAndServices.cmd"
ENDLOCAL

EXIT /B
)
:runMsiExec
(
%SystemRoot%\System32\msiexec.exe %*
IF ERRORLEVEL 1618 IF NOT ERRORLEVEL 1619 ( PING 127.0.0.1 -n 30 >NUL & GOTO :runMsiExec ) & rem another install in progress, wait and retry
EXIT /B
)
