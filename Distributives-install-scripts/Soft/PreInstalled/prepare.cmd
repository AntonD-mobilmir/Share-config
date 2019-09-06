@(REM coding:CP866
REM Script to unpack preinstalled and no-install software to new PCs
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
    IF NOT DEFINED ErrorCmd (
	SET "ErrorCmd=SET ErrorPresence=1"
	SET "ErrorPresence="
    )
    SET "utilsdir=%~dp0utils\"

    SET "OS64Bit="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"
    
    IF NOT DEFINED exename7za IF DEFINED OS64Bit ( SET "exename7za=7za64.exe" ) ELSE ( SET "exename7za=7za.exe" )
    IF NOT DEFINED exenameAutohotkey IF DEFINED OS64Bit ( SET "exenameAutohotkey=AutoHotkeyU64.exe" ) ELSE ( SET "exenameAutohotkey=AutoHotkey.exe" )
)
(
    IF NOT DEFINED exe7z SET exe7z="%utilsdir%%exename7za%"
    IF NOT DEFINED AutohotkeyExe SET AutohotkeyExe="%utilsdir%%exenameAutohotkey%"

    FOR /F "usebackq delims=" %%I IN (`DIR /B /ON "%~dp0auto\*.cmd"`) DO (
	ECHO %%~nI
	CALL "%~dp0auto\%%~I"
    )
)
EXIT /B %ErrorPresence%
