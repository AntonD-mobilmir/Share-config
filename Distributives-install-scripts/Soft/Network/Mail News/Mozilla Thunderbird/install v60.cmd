@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
    CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
    SET "distFullPath=%~dp0"
    SET "srcpath=%~dp0v60\"
    CALL "%~dp0find_distributive.cmd" || EXIT /B
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
)
(
    SET "MozMainSvcUninst=%lProgramFiles%\Mozilla Maintenance Service\Uninstall.exe"
    SET "KeepExtensions="
    IF EXIST "%lProgramFiles%\Mozilla Thunderbird\distribution\extensions" SET "KeepExtensions=1"
    SET "ErrorMemory="
    "%distFullPath%" /INI="%srcpath%install.ini" || CALL :SetErrorMemory
    REM Default extensions
    IF NOT DEFINED KeepExtensions RD /S /Q "%lProgramFiles%\Mozilla Thunderbird\distribution\extensions"
)
(
    REM Update Service
    IF EXIST "%MozMainSvcUninst%" "%MozMainSvcUninst%" /S
    IF NOT DEFINED ErrorMemory EXIT /B 0
)
EXIT /B %ErrorMemory%
:SetErrorMemory
(
    SET "ErrorMemory=%ERRORLEVEL%"
EXIT /B
)
