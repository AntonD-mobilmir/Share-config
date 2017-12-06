@(REM coding:CP866
ECHO OFF
ECHO Подготовка профиля пользователя к первому запуску, подождите.
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
    SET "srcpath=%~dp0"
    SET "RegTmpDir=%TEMP%\%~n0-reg"
    rem IF NOT DEFINED DefaultsSource EXIT /B 32010

    rem TeamViewer Settings
    ECHO N|REG ADD "HKEY_CURRENT_USER\Software\TeamViewer\Version5.1" /v Username /t REG_SZ /d "%UserName% \\%COMPUTERNAME%"
    REG ADD "HKEY_CURRENT_USER\Software\TeamViewer\Version5.1" /v ShowTaskbarInfoOnMinimize /t REG_DWORD /d 0 /f

    IF /I "%USERNAME%"=="Продавец" SET "RemoveAllAppX=1"
    IF /I "%USERNAME%"=="Пользователь" SET "RemoveAllAppX=1"
    IF /I "%USERNAME%"=="Install" SET "RemoveAllAppX=1"
)
:GetDefaultConfigDirAgain
CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
CALL :GetDir ConfigDir "%DefaultsSource%"
(
    CALL "%ConfigDir%_Scripts\find7zexe.cmd"
    CALL "%ConfigDir%_Scripts\FindAutoHotkeyExe.cmd" "%ConfigDir%_Scripts\cleanup\uninstall\050 OneDrive.ahk"
    FOR %%A IN ("\\Srv0.office0.mobilmir\profiles$\Share\config\Users\Default\AppData\Local\mobilmir.ru" "%ConfigDir%Users\Default\AppData\Local\mobilmir.ru" "%LOCALAPPDATA%\mobilmir.ru" "%USERPROFILE%\..\Default\AppData\Local\mobilmir.ru" "%SystemDrive%\Users\Default\AppData\Local\mobilmir.ru") DO IF EXIST "%%~A\DefaultUserRegistrySettings.7z" (
	SET "regDfltNewUser=%%~A\DefaultUserRegistrySettings.7z"
	SET "dirNewUserDefaults=%%~A"
	GOTO :NewUserDefaultsFound
    )
    ECHO Не найдена папка с настройками по умолчанию.
    ECHO Нажмите любую клавишу, чтобы повторить поиск, или закройте окно, чтобы отложить.
    PAUSE>NUL
    GOTO :GetDefaultConfigDirAgain
)
:NewUserDefaultsFound
(
    REM invoked above with 050 OneDrive.ahk -- CALL "%ConfigDir%_Scripts\FindAutoHotkeyExe.cmd"
    IF EXIST "%regDfltNewUser%" (
	IF DEFINED exe7z %exe7z% x -o"%RegTmpDir%" -- "%regDfltNewUser%"
	FOR /R %%I IN ("%RegTmpDir%\*.reg") DO REG IMPORT "%%~fI"
	RD /S /Q "%RegTmpDir%"
	IF NOT "%regDfltNewUser:~0,2%"=="\\" DEL "%regDfltNewUser%"
    )
    IF DEFINED RemoveAllAppX (
	START "Удаление всех Metro-приложений" %comspec% /C ""%ConfigDir%_Scripts\cleanup\AppX\Remove All AppX Apps for current user.cmd" /firstlogon"
    ) ELSE (
	START "Удаление Metro-приложений, кроме разрешенных" %comspec% /C ""%ConfigDir%_Scripts\cleanup\AppX\Remove AppX Apps except allowed.cmd" /firstlogon"
    )
    
    FOR %%A IN ("%dirNewUserDefaults%\RunOnce\*.cmd" "%dirNewUserDefaults%\RunOnce\*.ahk") DO (
	IF /I "%%~xA"==".cmd" (
	    CALL "%%~A"
	) ELSE IF /I "%%~xA"==".ahk" (
	    %AutohotkeyExe% "%%~fA"
	)
    )
    
    IF NOT "%srcpath:~0,2%"=="\\" DEL "%~f0"
    EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
