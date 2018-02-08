@(REM coding:CP866
REM Script to unpack preinstalled and no-install software to new PCs
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
    SET "utilsdir=%~dp0utils\"
    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
    IF NOT DEFINED ErrorCmd (
	SET "ErrorCmd=SET ErrorPresence=1"
	SET "ErrorPresence=0"
    )
    FOR /F "usebackq delims=" %%I IN (`DIR /B /ON "%~dp0auto\*.cmd"`) DO (
	ECHO %%~nI
	CALL "%~dp0auto\%%~I"
    )
)
EXIT /B %ErrorPresence%
