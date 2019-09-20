@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED exe7z CALL "%~dp0find7zexe.cmd" || EXIT /B
    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
    CALL "%~dp0CheckWinVer.cmd" 6
)
(
    IF NOT ERRORLEVEL 1 (
        CALL "%~dp0Default User\copyDefaultUserProfile.6.cmd"
    ) ELSE CALL "%~dp0Default User\copyDefaultUserProfile.XP.cmd"

    IF DEFINED Distributives CALL "%Distributives%\Soft\Network\HTTP\Google Chrome\copyDefaultSettings.cmd"
)
