@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

CALL :bg "%~dp0Security\AppLocker - Deny promoted apps Win10.cmd"
CALL :bg "%~dp0cleanup\AppX\Remove AppX Apps except allowed.cmd" /quiet
CALL :bg "%~dp0cleanup\AppX\Remove All AppX Apps for current user.cmd" /firstlogon
CALL :bg "%~dp0registry\DefaultUserRegistrySettings.cmd"

CALL :bg "%~dp0FindAutoHotkeyExe.cmd" "%~dp0cleanup\uninstall\050 OneDrive.ahk"
EXIT /B
)

:bg
(
    START "Running %~nx1" /LOW %comspec% /C "%*"
EXIT /B
)
