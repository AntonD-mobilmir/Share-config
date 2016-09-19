@(REM coding:CP866
rem script to disable data collection and telemetry
rem according to http://winaero.com/blog/how-to-disable-telemetry-and-data-collection-in-windows-10/
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"


%SystemRoot%\System32\reg.exe ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /d 0 /t REG_DWORD /f

%SystemRoot%\System32\sc.exe config "Diagnostics Tracking Service" start= disabled
%SystemRoot%\System32\sc.exe config "Connected User Experiences and Telemetry" start= disabled
%SystemRoot%\System32\sc.exe config "dmwappushsvc" start= disabled
)
