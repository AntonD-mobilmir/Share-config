@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

rem exit if winver is less than Win7
CALL "%ConfigDir%_Scripts\CheckWinVer.cmd" 6.1 || EXIT /B
rem exit if winver is higher or equal to Win8.1
CALL "%ConfigDir%_Scripts\CheckWinVer.cmd" 6.4 && EXIT /B

REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v "IncludeRecommendedUpdates" /d 0 /f
)
