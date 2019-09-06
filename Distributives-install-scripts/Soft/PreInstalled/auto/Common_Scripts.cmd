@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    IF NOT DEFINED ErrorCmd (
	SET "ErrorCmd=SET ErrorPresence=1"
	SET "ErrorPresence="
    )
    IF NOT EXIST "%ProgramData%\mobilmir.ru\Common_Scripts" (
	IF EXIST "%SystemDrive%\Common_Scripts" (
	    MOVE /Y "%SystemDrive%\Common_Scripts" "%ProgramData%\mobilmir.ru\Common_Scripts"
	) ELSE MKDIR "%ProgramData%\mobilmir.ru\Common_Scripts"
    )

    SET "utilsdir=%~dp0..\utils\"
    
    SET "OS64Bit="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"
    
    IF NOT DEFINED exename7za IF DEFINED OS64Bit ( SET "exename7za=7za64.exe" ) ELSE ( SET "exename7za=7za.exe" )
    IF NOT DEFINED exenameAutohotkey IF DEFINED OS64Bit ( SET "exenameAutohotkey=AutoHotkeyU64.exe" ) ELSE ( SET "exenameAutohotkey=AutoHotkey.exe" )
)
(
    IF NOT DEFINED exe7z SET exe7z="%utilsdir%%exename7za%"
    IF NOT DEFINED AutohotkeyExe SET AutohotkeyExe="%utilsdir%%exenameAutohotkey%"
)
(
    %exe7z% x -r -aoa "%~dpn0.7z" -o"%ProgramData%\mobilmir.ru\Common_Scripts" || %ErrorCmd%
    %windir%\System32\compact.exe /C /EXE:LZX /S:"%ProgramData%\mobilmir.ru\Common_Scripts" /I /Q || %windir%\System32\compact.exe /C /S:"%ProgramData%\mobilmir.ru\Common_Scripts" /I /Q
    
    SET "PATH=%PATH%;%ProgramData%\mobilmir.ru\Common_Scripts"
    %AutohotkeyExe% "%utilsdir%pathman.ahk" /as "%ProgramData%\mobilmir.ru\Common_Scripts"

    IF NOT DEFINED ErrorPresence EXIT /B 0
)
EXIT /B %ErrorPresence%
