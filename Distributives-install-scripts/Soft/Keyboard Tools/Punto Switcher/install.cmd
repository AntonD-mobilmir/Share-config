@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET "lProgramFiles=%ProgramFiles%"
IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"
)
(
REM Чтобы Punto Switcher не ругался при установке, что не может прочитать настройки и они будут заменены [потом можно]
MOVE /Y "%AppData%\Yandex" "%AppData%\Yandex_"
MOVE /Y "%AppData%\Yandex\Punto Switcher" "%AppData%\Yandex\Punto Switcher_"
"%~dp0PuntoSwitcherSetup.exe" /quiet /norestart
%SystemRoot%\System32\TASKKILL.exe /F /IM punto.exe
%SystemRoot%\System32\TASKKILL.exe /F /IM ps64ldr.exe

REM Можно вернуть возможно_битые настройки обратно
MOVE /Y "%AppData%\Yandex_" "%AppData%\Yandex"
MOVE /Y "%AppData%\Yandex\Punto Switcher_" "%AppData%\Yandex\Punto Switcher"

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
