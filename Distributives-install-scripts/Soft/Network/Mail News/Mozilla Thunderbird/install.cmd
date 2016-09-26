@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET "lProgramFiles=%ProgramFiles%"
IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"
CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
)
(
SET "MozMainSvcUninst=%lProgramFiles%\Mozilla Maintenance Service\Uninstall.exe"
CALL "%srcpath%find_distributive.cmd" || EXIT /B
IF NOT DEFINED distFullPath EXIT /B 1
)
"%distFullPath%" /INI="%srcpath%install.ini"
(

IF ERRORLEVEL 1 SET "ErrorMemory=%ERRORLEVEL%"
REM Default extensions
RD /S /Q "%lProgramFiles%\Mozilla Thunderbird\distribution\extensions"
REM Update Service
IF EXIST "%MozMainSvcUninst%" "%MozMainSvcUninst%" /S
)
EXIT /B %ErrorMemory%
