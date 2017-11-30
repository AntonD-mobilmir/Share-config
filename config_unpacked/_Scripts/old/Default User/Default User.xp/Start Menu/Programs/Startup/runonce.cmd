@(REM coding:CP866
ECHO OFF
ECHO Подготовка профиля пользователя к первому запуску, подождите.
CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
IF NOT DEFINED DefaultsSource EXIT /B 32010
SET "RegTmpDir=%TEMP%\%~n0 %DATE% %TIME::=%"

rem TeamViewer Settings
ECHO N|REG ADD "HKEY_CURRENT_USER\Software\TeamViewer\Version5.1" /v Username /t REG_SZ /d "%UserName% \\%COMPUTERNAME%"
REG ADD "HKEY_CURRENT_USER\Software\TeamViewer\Version5.1" /v ShowTaskbarInfoOnMinimize /t REG_DWORD /d 0 /f
)
CALL :GetDir ConfigDir "%DefaultsSource%"
(
FOR %%A IN ("%LOCALAPPDATA%\mobilmir.ru\DefaultUserRegistrySettings.7z" "%USERPROFILE%\..\Default\AppData\Local\mobilmir.ru\DefaultUserRegistrySettings.7z" "%ConfigDir%Users\Default\AppData\Local\mobilmir.ru\DefaultUserRegistrySettings.7z" "\\Srv0.office0.mobilmir\profiles$\Share\config\Users\Default\AppData\Local\mobilmir.ru\DefaultUserRegistrySettings.7z") IF EXIST %%A SET "DefaultUserRegistrySettings=%%~A"
CALL "%ConfigDir%_Scripts\find7zexe.cmd"
)
IF EXIST "%DefaultUserRegistrySettings%" (
    IF DEFINED exe7z %exe7z% x -o"%RegTmpDir%" -- "%DefaultUserRegistrySettings%"
    FOR /R %%I IN ("%RegTmpDir%\*.reg") DO REG IMPORT "%%~fI"
    RD /S /Q "%RegTmpDir%"
    DEL "%DefaultUserRegistrySettings%"
)
(
DEL "%~f0"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
