@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF DEFINED ProgramFiles^(x86^) (SET "lProgramFiles=%ProgramFiles(x86)%") ELSE SET "lProgramFiles=%ProgramFiles%"

rem \\Srv0.office0.mobilmir\profiles$\Share
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
)
CALL :GetDir ConfigDir "%DefaultsSource%"
(
CALL "%ConfigDir%\_Scripts\Security\FSACL_DOL2.cmd"
START "" "%lProgramFiles%\Internet Explorer\iexplore.exe" https://dealer.beeline.ru/dealer/DOL2/DOL.application
EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
