@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
SET "LocalPSSettingRel=Yandex\Punto Switcher"
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
IF NOT DEFINED DefaultsSource EXIT /B 129
IF NOT DEFINED exe7z CALL :find7zexe
)
(
%exe7z% x -aoa -o"%APPDATA%" -- "%configDir%_Scripts\Default User\default_AppDataRoaming.7z" "%LocalPSSettingRel%"
IF NOT EXIST "%APPDATA%\%LocalPSSettingRel%" MKDIR "%APPDATA%\%LocalPSSettingRel%"
XCOPY "%configDir%Users\Default\AppData\Roaming\%LocalPSSettingRel%\*.*" "%APPDATA%\%LocalPSSettingRel%" /E /I /Q /G /H /K /Y
%exe7z% x -aoa -y -o"%ProgramFiles%" -- "%DefaultsSource%" "%LocalPSSettingRel%"

EXIT /B
)
:find7zexe
IF NOT DEFINED configDir CALL :GetDir configDir "%DefaultsSource%"
(
    CALL "%configDir%_Scripts\find7zexe.cmd"
    IF NOT DEFINED exe7z (
        IF EXIST "%~dp0..\..\PreInstalled\utils\7za.exe" (
            SET exe7z="%~dp0..\..\PreInstalled\utils\7za.exe"
        ) ELSE SET "exe7z=7z.exe"
    )
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
