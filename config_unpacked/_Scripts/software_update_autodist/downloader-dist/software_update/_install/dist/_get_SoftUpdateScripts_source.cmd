@(REM coding:CP866
REM Script gets environment variables for software_update.cmd
REM depending to hostname
REM                                     Automated software update scripts
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

    SET "s_usHost="
    FOR /F "usebackq delims=" %%A IN ("%~dp0SoftUpdateScripts_source.txt") DO (
        IF NOT DEFINED s_usHost (
            SET "s_usHost=%%A"
        ) ELSE SET "s_usPath=%%A"
    )
    
    IF NOT DEFINED s_usPath (
        ECHO � "%~dp0SoftUpdateScripts_source.txt" ������ ���� 㪠��� hostname �ࢥ� [�᫨ ��ࢠ� ��ப� �����, � �ࢥ� = ������� ��������] � ���� �� �ࢥ� � ��饩 ����� �ਯ⮢ software_update [���� ������� ���� � �����, �᫨ ��ࢠ� ��ப� �����].
        EXIT /B -1
    )
    SET "s_uscriptsLocalStatus="
    IF EXIST "%PROGRAMDATA%\mobilmir.ru\SoftUpdateScripts\status\*.*" (
        SET "s_uscriptsLocalStatus=1"
    ) ELSE (
        FOR /F "usebackq tokens=2*" %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "hostname=%%~J"
        IF NOT DEFINED hostname SET "hostname=%COMPUTERNAME%"
    )
)
(
    IF DEFINED s_usHost (
        SET "Distributives=\\%s_usHost%\Distributives"
        SET "s_uscripts=\\%s_usHost%\%s_usPath%\client_exec"
    ) ELSE (
        SET "Distributives=D:\Distributives"
        SET "s_uscripts=D:\Local_Scripts\software_update\client_exec"
        SET "s_uscriptsLocalStatus=1"
    )
    
    IF NOT DEFINED s_uscriptsLocalStatus (
        IF NOT EXIST "\\%s_usHost%\%s_usPath%\status\%hostname%" MKDIR "\\%s_usHost%\%s_usPath%\status\%hostname%"
	ECHO.>"\\%s_usHost%\%s_usPath%\status\%hostname%\test.tmp" || SET "s_uscriptsLocalStatus=1"
	IF EXIST "\\%s_usHost%\%s_usPath%\status\%hostname%\test.tmp" (
            DEL "\\%s_usHost%\%s_usPath%\status\%hostname%\test.tmp"
        ) ELSE (
            SET "s_uscriptsLocalStatus=1"
        )
    )
    
    IF DEFINED s_uscriptsLocalStatus (
        SET "s_uscriptsStatus=%PROGRAMDATA%\mobilmir.ru\SoftUpdateScripts\status"
        SET "s_uscriptsOldLogs=%PROGRAMDATA%\mobilmir.ru\SoftUpdateScripts\old\status"
    ) ELSE (
        SET "s_uscriptsStatus=\\%s_usHost%\%s_usPath%\status\%hostname%"
        rem -- ⮫쪮 �� �ᯮ�짮����� s_uscriptsLocalStatus, ���� ��⪠ �믮������ �ࢥ஬ -- SET "s_uscriptsOldLogs=\\%s_usHost%\%s_usPath%\old\status\%hostname%"
    )
)
