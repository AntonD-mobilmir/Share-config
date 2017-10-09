@(
REM coding:OEM
ECHO OFF
ECHO �����⮢�� ��䨫� ���짮��⥫� � ��ࢮ�� ������, ��������.
CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
IF NOT DEFINED DefaultsSource EXIT /B 32010
SET RegTmpDir=%TEMP%\DefaultUserRegistrySettings
SET DefaultUserRegistrySettings=%LOCALAPPDATA%\DefaultUserRegistrySettings.7z

rem TeamViewer Settings
ECHO N|REG ADD "HKEY_CURRENT_USER\Software\TeamViewer\Version5.1" /v Username /t REG_SZ /d "%UserName% \\%COMPUTERNAME%"
REG ADD "HKEY_CURRENT_USER\Software\TeamViewer\Version5.1" /v ShowTaskbarInfoOnMinimize /t REG_DWORD /d 0 /f
)
IF NOT EXIST "%DefaultUserRegistrySettings%" SET DefaultUserRegistrySettings=%USERPROFILE%\..\Default\AppData\Local\DefaultUserRegistrySettings.7z
CALL :GetDir ConfigDir "%DefaultsSource%"
CALL "%ConfigDir%_Scripts\find7zexe.cmd"
IF EXIST "%DefaultUserRegistrySettings%" (
    IF DEFINED exe7z %exe7z% x -o"%RegTmpDir%" -- "%DefaultUserRegistrySettings%"
    FOR /R %%I IN ("%RegTmpDir%\*.reg") DO REG IMPORT "%%~fI"
    RD /S /Q "%RegTmpDir%"
    DEL "%DefaultUserRegistrySettings%"
)
:skipDUReg
(
DEL "%~f0"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)