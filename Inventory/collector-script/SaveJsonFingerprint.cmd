@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

CALL "%~dp0..\..\config\_Scripts\FindAutoHotkeyExe.cmd" || EXIT /B
FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
FOR /f "usebackq tokens=3*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname"`) DO SET "NVHostname=%%~J"
SET "cTime=%TIME::=%"
SET "cDate=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%"
)
(
IF EXIST "%ProgramData%\mobilmir.ru\trello-id.txt" COPY /B /Y "%ProgramData%\mobilmir.ru\trello-id.txt" "%~dp0trello-accounting-update-queue\%Hostname% %cDate% %cTime:,=.% trello-id.txt"
%AutohotkeyExe% "%~dp0..\..\config\_Scripts\Lib\GetFingerprint.ahk" "%~dp0trello-accounting-update-queue\%Hostname% %cDate% %cTime:,=.%.txt" /json "%~dp0trello-accounting-update-queue\%Hostname% %cDate% %cTime:,=.%.json"
)
