@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

    MKDIR "%TEMP%\%~n0.tmp"
    SET "tmp=%TEMP%\%~n0.tmp"

    CALL :bg "%~dp0Security\AppLocker - Deny promoted apps Win10.cmd"
    CALL :bg "%~dp0registry\DefaultUserRegistrySettings.cmd"

    CALL :bg "%~dp0FindAutoHotkeyExe.cmd" "%~dp0cleanup\uninstall\050 OneDrive.ahk"

    powershell.exe -command "Get-AppXPackage | Format-Table -GroupBy PublisherId | Out-String -Width 1048576 | Out-File "%TEMP%\all-AppXPackages.txt""

    CALL :bg "%~dp0cleanup\AppX\Remove AppX Apps except allowed.cmd" /quiet
)
:again
@(
    IF EXIST "%tmp%\*.tmp" (
        PING -n 3 127.0.0.1 >NUL
        FOR %%A IN ("%tmp%\*.tmp") DO MOVE /Y "%%~A" "%%~dpnA.log" >NUL 2>NUL
        GOTO :again
    )
    
    CALL :bg "%~dp0cleanup\AppX\Remove All AppX Apps for current user.cmd" /firstlogon
EXIT /B
)

:bg
(
    START "Running %~nx1" /LOW %comspec% /C "%* >"%tmp%\%~nx1.tmp" 2>&1"
EXIT /B
)
