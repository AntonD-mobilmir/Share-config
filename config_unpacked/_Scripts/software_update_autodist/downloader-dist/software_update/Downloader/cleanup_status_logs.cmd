@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    CALL :RunFromConfig _Scripts\FindAutoHotkeyExe.cmd
    IF NOT DEFINED s_uscriptsOldLogs CALL "%ProgramData%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd"
)
(
    IF DEFINED s_uscriptsOldLogs CALL :clean "%s_uscriptsOldLogs%\.."
    IF DEFINED s_uscriptsStatus "%s_uscriptsStatus%\.."
    IF EXIST "%~dp0software_update" CALL :clean "%~dp0software_update\old\status" "%~dp0software_update\status" "%~dp0software_update\client_exec"
EXIT /B
)

:clean <s_uscriptsOldLogsBase> <s_uscriptsStatusBase> <s_uscripts>
(
    START "" /LOW %AutohotkeyExe% /ErrorStdOut "%~3\..\maint\remove old files.ahk" "%~1"
    
    IF NOT EXIST "%~2\*.*" EXIT /B 1
    IF NOT EXIST "%~1\*.*" MKDIR "%~1"
    FOR /D %%A IN ("%~2\*.*") DO FOR %%I IN ("%%~A\*.*") DO IF NOT EXIST "%~3\%%~nI" (
        IF NOT EXIST "%~1\%%~A\*.*" MKDIR "%~1\%%~A"
        ECHO Y|MOVE /Y "%%~I" "%~1\%%~A\"
    )
EXIT /B
)

:RunFromConfig
IF NOT DEFINED configDir CALL :findconfigDir
(
    IF "%~x1"==".cmd" (
        CALL "%configDir%"%*
    ) ELSE "%configDir%"%*
    EXIT /B
)
:findconfigDir
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
(
    CALL :GetDir configDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
