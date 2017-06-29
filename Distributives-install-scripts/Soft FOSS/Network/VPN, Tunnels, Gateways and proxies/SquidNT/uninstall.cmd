@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

C:\squid\sbin\squid.exe -r
C:\squid\sbin\squid.exe -r squidnt
C:\squid\sbin\squid.exe -r squid

RD /S /Q C:\squid
%SystemRoot%\System32\schtasks.exe /Delete /TN squid_start /F
%SystemRoot%\System32\schtasks.exe /Delete /TN squid_reconfig /F
%SystemRoot%\System32\schtasks.exe /Delete /TN squid_logrorate /F

RD /S /Q D:\squid
)
