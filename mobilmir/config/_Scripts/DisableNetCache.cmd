@REM coding:CP866
@REM by LogicDaemon <www.logicdaemon.ru>
@REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\NetCache" /v "Enabled" /t REG_DWORD /d 0 /f
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\NetCache" /v "SyncAtLogon" /t REG_DWORD /d 0 /f
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\NetCache" /v "SyncAtLogoff" /t REG_DWORD /d 0 /f
