@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"

IF DEFINED DefaultsSource CALL :getDir DefaultsSourceDir "%DefaultsSource%"
IF "%DefaultsSourceDir%"=="" (
    ECHO Cannot get DefaultsSource dir location!
    EXIT /B 1
)

:next
IF NOT EXIST "%~dp1" MKDIR "%~dp1"
CALL "%DefaultsSourceDir%_Scripts\rSync_DistributivesFromSrv0.cmd" "%~dp1"
START "Installing %~1" /WAIT %comspec% /C %1

IF NOT "%~2"=="" (
    SHIFT
    GOTO :next
)

EXIT /B

:getDir
    SET "%~1=%~dp2"
EXIT /B
