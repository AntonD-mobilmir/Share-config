@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF NOT DEFINED ErrorCmd (
    SET "ErrorCmd=SET ErrorPresence=1"
    SET "ErrorPresence=0"
)
)
IF "%utilsdir%"=="" SET utilsdir=%srcpath%..\utils\
(
IF NOT EXIST "%ProgramData%\mobilmir.ru\Common_Scripts" (
    IF EXIST "%SystemDrive%\Common_Scripts" (
	MOVE /Y "%SystemDrive%\Common_Scripts" "%ProgramData%\mobilmir.ru\Common_Scripts"
    ) ELSE MKDIR "%ProgramData%\mobilmir.ru\Common_Scripts"
)
"%utilsdir%7za.exe" x -r -aoa "%srcpath%%~n0.7z" -o"%ProgramData%\mobilmir.ru\Common_Scripts" || %ErrorCmd%
%windir%\System32\compact.exe /C /EXE:LZX /S:"%ProgramData%\mobilmir.ru\Common_Scripts" /I /Q || %windir%\System32\compact.exe /C /S:"%ProgramData%\mobilmir.ru\Common_Scripts" /I /Q
"%utilsdir%xln.exe" -n "%ProgramData%\mobilmir.ru\Common_Scripts" "%SystemDrive%\Common_Scripts"
)
EXIT /B %ErrorPresence%
