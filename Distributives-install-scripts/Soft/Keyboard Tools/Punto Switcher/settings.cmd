@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
IF NOT DEFINED DefaultsSource EXIT /B 129
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
SET "LocalPSSettingRel=Yandex\Punto Switcher"
)
CALL :GetDir ConfigDir "%DefaultsSource%"
IF NOT DEFINED exe7z CALL "%ConfigDir%_Scripts\find7zexe.cmd"
(
%exe7z% x -aoa -o"%APPDATA%" -- "%ConfigDir%_Scripts\Default User\default_AppDataRoaming.7z" "%LocalPSSettingRel%"
IF NOT EXIST "%APPDATA%\%LocalPSSettingRel%" MKDIR "%APPDATA%\%LocalPSSettingRel%"
XCOPY "%ConfigDir%Users\Default\AppData\Roaming\%LocalPSSettingRel%\*.*" "%APPDATA%\%LocalPSSettingRel%" /E /I /Q /G /H /K /Y
%exe7z% x -aoa -o"%ProgramFiles%" -- "%DefaultsSource%" "%LocalPSSettingRel%"

EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
