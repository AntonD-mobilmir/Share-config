@REM coding:CP866
(
    IF NOT DEFINED dest7zinst FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CURRENT_USER\Software\7-Zip" /v "Path" /reg:64`) DO SET dest7zinst=%%B
    IF NOT DEFINED dest7zinst FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\7-Zip" /v "Path" /reg:64`) DO SET dest7zinst=%%B
    IF NOT DEFINED dest7zinst FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path" /reg:64`) DO SET dest7zinst=%%B
    IF NOT DEFINED dest7zinst FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve /reg:64`) DO SET dest7zinst=%%~dpB
    IF NOT DEFINED dest7zinst FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation" /reg:64`) DO SET dest7zinst=%%~dpB
)
IF NOT EXIST "%dest7zinst%" EXIT /B 1
IF "%dest7zinst:~-1%"=="\" SET dest7zinst=%dest7zinst:~,-1%
