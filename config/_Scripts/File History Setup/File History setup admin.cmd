(REM coding:CP866
REM localconfigpath = %1
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

rem as admin:
rem IF NOT "%~1"=="" REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\fhsvc\Parameters\Configs" /v %1 /t REG_DWORD /d 1 /f
CALL "%~dp0..\share File History for Windows 8.cmd"

rem %SystemRoot%\System32\sc.exe config fhsvc start= delayed-auto
rem %SystemRoot%\System32\sc.exe start fhsvc


)
