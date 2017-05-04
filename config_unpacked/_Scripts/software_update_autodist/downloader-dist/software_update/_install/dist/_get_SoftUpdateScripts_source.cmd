@(REM coding:CP866
REM Script gets environment variables for software_update.cmd
REM depending to hostname
REM                                     Automated software update scripts
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

SET SUSHost={$SUSHost$}
SET SUSPath=SoftUpdateScripts$

FOR /F "usebackq tokens=2*" %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "hostname=%%~J"
IF NOT DEFINED hostname SET "hostname=%COMPUTERNAME%"
)
(
SET "SUScripts=\\%SUSHost%\%SUSPath%\scripts"
SET "Distributives=\\%SUSHost%\Distributives"
SET SUScriptsStatus=\\%SUSHost%\%SUSPath%\status\%hostname%
SET SUScriptsOldLogs=\\%SUSHost%\%SUSPath%\old\status\%hostname%
)
