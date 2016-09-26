@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET "lProgramFiles=%ProgramFiles%"
IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"
)
(
"%~dp0PuntoSwitcherSetup.exe" /quiet /norestart
%SystemRoot%\System32\TASKKILL.exe /F /IM punto.exe
%SystemRoot%\System32\TASKKILL.exe /F /IM ps64ldr.exe

CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" & IF NOT DEFINED DefaultsSource EXIT /B
RD /S /Q "%ProgramFiles%\Yandex\Punto Switcher\Images" 
RD /S /Q "%ProgramFiles%\Yandex\Punto Switcher\Updater"
)
(
CALL :GetDir ConfigDir "%DefaultsSource%"
SET "NoSetACL=1"
)
(
CALL "%ConfigDir%_Scripts\copyDefaultUserProfile.cmd"

CALL "%~dp0settings.cmd"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
