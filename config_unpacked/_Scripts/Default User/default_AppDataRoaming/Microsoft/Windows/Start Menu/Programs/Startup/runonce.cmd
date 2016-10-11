@(REM coding:CP866
    ECHO OFF
    ECHO Подготовка профиля пользователя к первому запуску, подождите.
    REM by LogicDaemon <www.logicdaemon.ru>
    REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    SET "RegTmpDir=%TEMP%\DefaultUserRegistrySettings"
    SET "DefaultUserRegistrySettings=%LOCALAPPDATA%\DefaultUserRegistrySettings.7z"

    CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
    IF NOT DEFINED DefaultsSource EXIT /B 32010

    rem TeamViewer Settings
    ECHO N|REG ADD "HKEY_CURRENT_USER\Software\TeamViewer\Version5.1" /v Username /t REG_SZ /d "%UserName% \\%COMPUTERNAME%"
    REG ADD "HKEY_CURRENT_USER\Software\TeamViewer\Version5.1" /v ShowTaskbarInfoOnMinimize /t REG_DWORD /d 0 /f

    IF NOT EXIST "%DefaultUserRegistrySettings%" SET "DefaultUserRegistrySettings=%USERPROFILE%\..\Default\AppData\Local\DefaultUserRegistrySettings.7z"
)
CALL :GetDir ConfigDir "%DefaultsSource%"
CALL "%ConfigDir%_Scripts\find7zexe.cmd"
(
    IF EXIST "%DefaultUserRegistrySettings%" (
	IF DEFINED exe7z %exe7z% x -o"%RegTmpDir%" -- "%DefaultUserRegistrySettings%"
	FOR /R %%I IN ("%RegTmpDir%\*.reg") DO REG IMPORT "%%~fI"
	RD /S /Q "%RegTmpDir%"
	DEL "%DefaultUserRegistrySettings%"
    )
    IF /I "%USERNAME%"=="Продавец" SET "RemoveAllAppX=1"
    IF /I "%USERNAME%"=="Пользователь" SET "RemoveAllAppX=1"
    IF /I "%USERNAME%"=="Install" SET "RemoveAllAppX=1"
    IF DEFINED RemoveAllAppX (
	CALL "%ConfigDir%_Scripts\cleanup\AppX\Remove All AppX Apps for current user.cmd" /firstlogon
    ) ELSE (
	CALL "%ConfigDir%_Scripts\cleanup\AppX\Remove AppX Apps except allowed.cmd" /firstlogon
    )
    DEL "%~f0"
    EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
