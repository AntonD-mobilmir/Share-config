@(REM coding:CP866
REM Ahaap replied on  October 31, 2012
REM on https://answers.microsoft.com/en-us/protect/forum/mse-protect_start/error-code-0x80070645/27ef7f55-ebf6-42e2-a310-b09b2690b771
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
)
(
rem **** MSREMOVAL.TXT ****
cd /d "%ProgramFiles%\Microsoft Security Client"
START "" /WAIT setup.exe /x
TASKKILL /f /im MsMpEng.exe
TASKKILL /f /im msseces.exe
net stop MsMpSvc
sc delete MsMpSvc
REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\MsMpSvc" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Security Client" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Microsoft Antimalware" /f
REG DELETE "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\Current Version\Run\MSC" /f
REG DELETE "HKEY_CLASSES_ROOT\Installer\Products\4C677A77F01DD614880F352F9DCD9D3B" /f
REG DELETE "HKEY_CLASSES_ROOT\Installer\Products\4D880477777087D409D44E533B815F2D" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Security Client" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{774088D4-0777-4D78-904D-E435B318F5D2}" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{77A776C4-D10F-416D-88F0-53F2D9DCD9B3}" /f
REG DELETE "HKEY_CLASSES_ROOT\Installer\UpgradeCodes\1F69ACF0D1CF2B7418F292F0E05EC20B" /f
REG DELETE "HKEY_CLASSES_ROOT\Installer\UpgradeCodes\11BB99F8B7FD53D4398442FBBAEF050F" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\4C677A77F01DD614880F352F9DCD9D3B" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\4D880477777087D409D44E533B815F2D" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\11BB99F8B7FD53D4398442FBBAEF050F" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\1F69ACF0D1CF2B7418F292F0E05EC20B" /f
 
takeown /f "%ProgramData%\Microsoft\Microsoft Antimalware" /a /r
takeown /f "%ProgramData%\Microsoft\Microsoft Security Client" /a /r
takeown /f "%ProgramFiles%\Microsoft Security Client" /a /r
REM Delete the MSE folders.
rmdir /s /q "%ProgramData%\Microsoft\Microsoft Antimalware"
rmdir /s /q "%ProgramData%\Microsoft\Microsoft Security Client"
rmdir /s /q "%ProgramFiles%\Microsoft Security Client"
REM Stop the WMI and its dependency services
sc stop sharedaccess
sc stop mpssvc
sc stop wscsvc
sc stop iphlpsvc
sc stop winmgmt
REM Delete the Repository folder.
rmdir /s /q "C:\Windows\System32\wbem\Repository"
sc stop
EXIT
)
