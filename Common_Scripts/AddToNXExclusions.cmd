@REM coding:OEM
:again
IF "%~1"=="" EXIT /B
    REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v %1 /d "DisableNXShowUI"
GOTO :again
