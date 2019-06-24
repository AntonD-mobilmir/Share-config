@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SET "DefaultsSourceScript=%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
)
IF "%~1"=="" (
    CALL "%DefaultsSourceScript%"
    IF DEFINED DefaultsSource (
        CALL :UsePrefefinedDefaultsSource
    ) ELSE (
        IF EXIST "%~dp0..\Apps_roaming.7z" (
            CALL :SplitSrcConfigPath "%~dp0..\Apps_roaming.7z"
        ) ELSE GOTO :ErrorExit
    )
) ELSE CALL :GetConfigPathWithName "%~1" || GOTO :ErrorExit
rem old location: "%PROGRAMDATA%\mobilmir-config"
FOR /D %%I IN ("D:\Distributives\config" "%PROGRAMDATA%\mobilmir.ru\config") DO (
    IF /I "%srcConfigDir%" EQU "%%~I" (
        ECHO Конфигурация уже в %%I.
        SET "configDir=%srcConfigDir%\"
        GOTO :ConfigCopied
    )
    ECHO Проверка "%%~I"...
    MKDIR "%%~I"
    IF EXIST "%%~I" (
        XCOPY "%srcConfigDir%" "%%~I" /E /C /I /H /K /Y && (
            SET "configDir=%%~I\"
            GOTO :ConfigCopied
        )
    )
)
:ConfigCopied
IF DEFINED configDir (
    SET "DefaultsSource=%configDir%%srcConfigName%"
) ELSE GOTO :ErrorExit
(
    ECHO Папка настроек: %configDir%
    IF NOT EXIST "%ProgramData%\mobilmir.ru" MKDIR "%ProgramData%\mobilmir.ru"
    ECHO SET "DefaultsSource=%DefaultsSource%">"%DefaultsSourceScript%"
    EXIT /B
)
:UsePrefefinedDefaultsSource
(
    CALL :SplitSrcConfigPath "%DefaultsSource%"
    CALL :GetName srcConfigName "%DefaultsSource%"
EXIT /B
)
:GetName <var> <path>
(
    SET "%~1=%~nx2"
EXIT /B
)
:GetConfigPathWithName
(
    IF EXIST "%~1" (
	CALL :SplitSrcConfigPath %1
    ) ELSE (
	IF EXIST "%~dp0..\%~1" (
	    CALL :SplitSrcConfigPath "%~dp0..\%~1"
	) ELSE EXIT /B 1
    )
EXIT /B
)
:SplitSrcConfigPath
(
    SET "srcConfigName=%~nx1"
    SET "srcConfigDir=%~dp1"
)
(	
    IF /I "%srcConfigDir:~1,9%"=="%windir:~1,9%" ECHO  & PAUSE & EXIT /B
    SET "srcConfigDir=%srcConfigDir:~0,-1%"
EXIT /B
)
:ErrorExit
    START "Ошибка при выполнении %~nx0" %comspec% /C ECHO Не удалось найти доступный путь для локальной копии папки настроек. Локальная копия не будет создана!^&PAUSE
    SET "DefaultsSource=%srcConfigDir%%srcConfigName%"
EXIT /B
