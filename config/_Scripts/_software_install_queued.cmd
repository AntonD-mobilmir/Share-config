@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "configScriptsDir=%CD%\") ELSE SET "configScriptsDir=%~dp0"
IF NOT DEFINED ProgramData (
    REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "ProgramData" /t REG_EXPAND_SZ /d "%%ALLUSERSPROFILE%%\Application Data" /f
    SET "ProgramData=%ALLUSERSPROFILE%\Application Data"
)
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

CALL "%~dp0FindSoftwareSource.cmd"
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
CALL "%~dp0FindAutoHotkeyExe.cmd"

IF NOT EXIST "%ProgramData%\mobilmir.ru\Logs" MKDIR "%ProgramData%\mobilmir.ru\Logs"
IF NOT DEFINED logfile SET logfile="%ProgramData%\mobilmir.ru\Logs\%~n0.log"

IF NOT DEFINED InstallQueue CALL "%~dp0Lib\.utils.cmd" GetInstallQueue InstallQueue

CALL "%~dp0FindSoftwareSource.cmd"
IF NOT DEFINED configDir CALL :GetconfigDir || SET "configDir=%~dp0..\"
)
SET "biglogfile=%logfile%"
(
CALL :Log SoftSourceDir: %SoftSourceDir%
CALL :Log DefaultsSource: %DefaultsSource%

FOR /F "usebackq delims=" %%A IN (`DIR /O-N /B "%InstallQueue%\*.cmd"`) DO (
    SET logfile="%TEMP%\%~n0 %%~nA.log"
    CALL :Log Запуск "%%~A", журнал в "%TEMP%\%~n0 %%~nA.log"
    %comspec% /C ""%InstallQueue%\%%~A"" && DEL "%InstallQueue%\%%~A"
    IF ERRORLEVEL 1 CALL :LogError
)
RD "%InstallQueue%"
CALL :Log Установка завершена.
EXIT /B
)
:LogError
(
ECHO %DATE% %TIME% ERRORLEVEL=%ERRORLEVEL%
(ECHO %DATE% %TIME% ERRORLEVEL=%ERRORLEVEL%
)>>%biglogfile%
(ECHO %DATE% %TIME% ERRORLEVEL=%ERRORLEVEL%
)>>%logfile%
EXIT /B
)
:Log
(
ECHO %DATE% %TIME% %*
(ECHO %DATE% %TIME% %*
)>>%biglogfile%
(ECHO %DATE% %TIME% %*
)>>%logfile%
EXIT /B
)
:GetconfigDir
(
CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
IF NOT DEFINED DefaultsSource EXIT /B 32010
)
(
CALL :GetDir configDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
