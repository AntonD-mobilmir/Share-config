@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
)

rem from http://answers.microsoft.com/en-us/windows/forum/windows_10-win_upgrade/i-want-to-reserve-my-free-copy-of-windows-10-but-i/848b5cce-958b-49ae-a132-a999a883265b?auth=1

REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\UpgradeExperienceIndicators" /v UpgEx | findstr UpgEx
if "%errorlevel%" == "0" GOTO RunGWX
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Appraiser" /v UtcOnetimeSend /t REG_DWORD /d 1 /f
schtasks /run /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
:CompatCheckRunning
schtasks /query /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
schtasks /query /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | findstr Готово
if NOT "%errorlevel%" == "0" ping localhost >nul &goto :CompatCheckRunning
:RunGWX
schtasks /run /TN "\Microsoft\Windows\Setup\gwx\refreshgwxconfig"
