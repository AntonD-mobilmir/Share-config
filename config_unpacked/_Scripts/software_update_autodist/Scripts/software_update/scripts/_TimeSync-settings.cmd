@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "0" /t REG_SZ /d "office0.mobilmir.ru,0x4" /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /ve /t REG_SZ /d "0" /f
