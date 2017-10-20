@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

%SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )
IF DEFINED PROCESSOR_ARCHITEW6432 "%SystemRoot%\SysNative\cmd.exe" /C "%0 %*" & EXIT /B
%SystemRoot%\System32\POWERCFG.exe /HIBERNATE /SIZE 40
IF NOT DEFINED SoftSourceDir CALL "%~dp0_Scripts\FindSoftwareSource.cmd"
)
(
rem IF NOT DEFINED instQuickConfig SET /P "instQuickConfig=Установить Intelloware Quick Config? [1=да, остальное=нет]"
rem IF "%instQuickConfig%"=="1" START "Установка Intelloware Quick Config" /WAIT /I msiexec.exe /i "%SoftSourceDir%\Network\Configuration\Intelloware Quick Config\QuickConfig.msi" /q
)
