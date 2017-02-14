@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "c:\Local_Scripts\_get_defaultconfig_source.cmd"
IF DEFINED DefaultsSource ( CALL :Find7zLocally ) ELSE CALL "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\find7zexe.cmd"
IF NOT DEFINED exe7z ( ECHO 7-Zip не найден. & PAUSE & EXIT /B )

%SystemRoot%\System32\net.exe stop squid
)
(
%exe7z% x -aoa -o"c:\squid" -- "%~dp0squid.2.7.7z"
PUSHD "C:\squid\sbin" && (
    CALL "C:\squid\sbin\install.cmd"
    POPD
)
EXIT /B
)
:Find7zLocally
    CALL :GetDir configDir "%DefaultsSource%"
(
    CALL "%configDir%_Scripts\find7zexe.cmd"
EXIT /B
)
:GetDir <var> <path>
(
    SET "%~1=%~dp2"
EXIT /B
)
