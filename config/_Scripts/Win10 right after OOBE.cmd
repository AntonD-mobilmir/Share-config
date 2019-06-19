@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

    MKDIR "%TEMP%\%~n0"
    SET "tmpd=%TEMP%\%~n0"
    SET /A "waitTime=10"

    CALL :bg "%~dp0Security\AppLocker - Deny promoted apps Win10.cmd"
    CALL :bg "%~dp0registry\DefaultUserRegistrySettings.cmd"
    IF /I "%USERNAME%"=="Install" SET "setTheme=1"
    IF /I "%USERNAME%"=="Anton.Derbenev" SET "setTheme=1"
    IF DEFINED setTheme (
        COPY /Y /B "%~dp0..\Users\Default\AppData\Local\mobilmir.ru\plain_grey_dark.deskthemepack" "%TEMP%\plain_grey_dark.deskthemepack"
        START "" "%TEMP%\plain_grey_dark.deskthemepack"
    )
    SET "setTheme=%setTheme%"

    CALL :bg "%~dp0FindAutoHotkeyExe.cmd" "%~dp0cleanup\uninstall\050 OneDrive.ahk"

    powershell.exe -command "Get-AppXPackage | Format-Table -GroupBy PublisherId | Out-String -Width 1048576 | Out-File "%TEMP%\all-AppXPackages.txt""

    CALL :bg "%~dp0cleanup\AppX\Remove AppX Apps except allowed.cmd" /quiet
)
:again
@(
    FOR %%A IN ("%tmpd%\*.tmp") DO @CALL :WaitRename "%%~A"
    CALL :bg "%~dp0cleanup\AppX\Remove All AppX Apps for current user.cmd" /firstlogon
EXIT /B
)

:bg
(
    START "Running %~nx1" /LOW %comspec% /C "%* >"%tmp%\%~nx1.tmp" 2>&1"
EXIT /B
)

:WaitRename
@(
    ECHO Waiting/Removing %1...
    IF EXIST "%~dpn1.log" MOVE /Y "%~dpn1.log" "%~dpn1.bak"
    IF EXIST "%~dpn1.log" EXIT /B 1
    REN /Y %1 "%~n1.log" >NUL 2>NUL
    IF EXIST "%1" (
        ECHO Waiting %1
        PING -n %waitTime% 127.0.0.1 >NUL
        GOTO :WaitRename
    )
    
    ECHO        ...OK
    EXIT /B 0
)
