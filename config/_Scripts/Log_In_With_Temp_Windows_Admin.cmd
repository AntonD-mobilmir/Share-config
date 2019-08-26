@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
FOR /F "usebackq delims=" %%A IN (`""%~dp0FindAutoHotkeyExe.cmd" "%~dp0Lib\GenPassword.ahk""`) DO IF NOT DEFINED tempPwd SET "tempPwd=%%~A"
CALL "%~dp0Log_In_With_Temp_Windows_Account.cmd" /admin
)
