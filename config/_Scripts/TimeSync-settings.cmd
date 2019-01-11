@REM coding:CP866
@REM by LogicDaemon <www.logicdaemon.ru>
@REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

SETLOCAL ENABLEEXTENSIONS
NET TIME \\Srv1S-B.office0.mobilmir /SET /Y
NET TIME \\Srv1S.office0.mobilmir /SET /Y
NET TIME \\Srv0.office0.mobilmir /SET /Y
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "0" /t REG_SZ /d "time.mobilmir.ru,0x4" /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /ve /t REG_SZ /d "0" /f
