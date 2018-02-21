@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

CALL "%~dp0Security\AppLocker - Deny promoted apps (Win10).cmd"
CALL "%~dp0cleanup\AppX\Remove AppX Apps except allowed.cmd" /quiet
CALL "%~dp0cleanup\AppX\Remove All AppX Apps for current user.cmd" /firstlogon
CALL "%~dp0registry\DefaultUserRegistrySettings.cmd"

CALL "%~dp0FindAutoHotkeyExe.cmd" "%~dp0cleanup\uninstall\050 OneDrive.ahk"
)
