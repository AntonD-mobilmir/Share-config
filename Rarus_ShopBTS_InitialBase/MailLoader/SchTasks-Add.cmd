@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

rem %System32%\SCHTASKS.exe /Delete /TN "mobilmir\%~n1" /F
%System32%\SCHTASKS.exe /Create /F /TN "mobilmir.ru\%~n1" /XML %* || EXIT /B
%System32%\SCHTASKS.exe /Run /TN "mobilmir.ru\%~n1"
EXIT /B
)
