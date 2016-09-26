@(REM coding:CP866
REM Script to unpack preinstalled and no-install software to new PCs
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
rem ECHO OFF
IF "%~dp0"=="" (SET "preparesrcpath=%CD%\") ELSE SET "preparesrcpath=%~dp0"
IF NOT DEFINED APPDATA "SET APPDATA=%USERPROFILE%\Application Data"
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
)
(
SET utilsdir=%preparesrcpath%utils\

IF NOT DEFINED ErrorCmd (
    SET "ErrorCmd=SET ErrorPresence=1"
    SET "ErrorPresence=0"
)
(
ASSOC .sh=ShellScript
FTYPE ShellScript=%SystemDrive%\SysUtils\UnxUtils\bash.exe "%%1"
ASSOC .log=logfile
FTYPE logfile=%SystemDrive%\SysUtils\UnxUtils\tail.exe -n 500 -f "%%1"
rem     ASSOC .pl=PerlScript
rem     FTYPE PerlScript=perl.exe "%%1"
rem     ASSOC .py=PythonScript
rem     FTYPE PythonScript=python.exe "%%1"
)
)
FOR /F "usebackq delims=" %%I IN (`DIR /B /ON "%preparesrcpath%auto\*.cmd"`) DO (
    ECHO %%~nI
    CALL "%preparesrcpath%auto\%%~I"
)
)
EXIT /B %ErrorPresence%
