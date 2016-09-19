@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
rem ignore for Win 8.1+
CALL "%~dp0CheckWinVer.cmd" 6.3 && EXIT /B

REG ADD "HKLM\SOFTWARE\Microsoft\Internet Explorer\Setup\11.0" /v "DoNotAllowIE11" /t REG_DWORD /d 1 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Internet Explorer\Setup\11.0" /v "DoNotAllowIE11" /t REG_DWORD /d 1 /f /reg:64
ENDLOCAL
)
