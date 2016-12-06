@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
)
IF "%~1"=="" (
    IF EXIST "%~dp0..\Apps_roaming.7z" (
	CALL :SplitSrcConfigPath "%~dp0..\Apps_roaming.7z"
    ) ELSE GOTO :ErrorExit
) ELSE IF NOT EXIST "%~1" (
    IF EXIST "%~dp0..\%~1" (
	CALL :SplitSrcConfigPath "%~dp0..\%~1"
    ) ELSE GOTO :ErrorExit
) ELSE CALL :SplitSrcConfigPath %1

rem old location: "%PROGRAMDATA%\mobilmir-config"
FOR /D %%I IN ("D:\Distributives\config" "W:\Distributives\config" "%PROGRAMDATA%\mobilmir.ru\config") DO (
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

ECHO Папка настроек: %configDir%
IF NOT EXIST "%ProgramData%\mobilmir.ru" MKDIR "%ProgramData%\mobilmir.ru"
SET "DefaultsSourceScript=%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
ECHO SET "DefaultsSource=%DefaultsSource%">"%DefaultsSourceScript%"

IF NOT EXIST "%ProgramData%\mobilmir.ru" CALL "%~dp0move Local_Scripts to ProgramData_mobilmir.cmd"
EXIT /B

:ErrorExit
    START "Ошибка при выполнении %~nx0" %comspec% /C ECHO Не удалось найти доступный путь для локальной копии папки настроек. Локальная копия не будет создана!^&PAUSE
    SET "DefaultsSource=%srcConfig%"
EXIT /B

:SplitSrcConfigPath
(
    SET "srcConfig=%~1"
    SET "srcConfigName=%~nx1"
    SET "srcConfigDir=%~dp1"
)
(	
    SET "srcConfigDir=%srcConfigDir:~0,-1%"
EXIT /B
)
