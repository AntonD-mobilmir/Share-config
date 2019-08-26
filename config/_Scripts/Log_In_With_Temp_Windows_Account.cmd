@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    IF "%~1"=="/Admin" SET "addAdminGroup=1"
    
    IF NOT DEFINED tempUserName SET "tempUserName=Temp"
)
(
    IF DEFINED tempPwd (
        NET USER "%tempUserName%" "%tempPwd%" /Add
    ) ELSE (
        NET USER "%tempUserName%" /Add
    )
    IF DEFINED addAdminGroup (
        "%SystemRoot%\System32\NET.exe" LOCALGROUP Administrators "%tempUserName%" /Add
        "%SystemRoot%\System32\NET.exe" LOCALGROUP Администраторы "%tempUserName%" /Add
    )
    REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /d "%tempUserName%" /f
    rem REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /d "%tempPwd%" /f
    REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /d "" /f
    REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /d 1 /f
    tsdiscon
    PING -n 15 127.0.0.1 > NUL
    
    REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /f
    REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /f
    REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /f
)
