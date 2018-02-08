@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    IF NOT DEFINED ErrorCmd (
	SET "ErrorCmd=SET ErrorPresence=1"
	SET "ErrorPresence=0"
    )
    IF NOT EXIST "%utilsdir%7za.exe" SET "utilsdir=%~dp0..\utils\"
    
    IF NOT EXIST "%ProgramData%\mobilmir.ru\Common_Scripts" (
	IF EXIST "%SystemDrive%\Common_Scripts" (
	    MOVE /Y "%SystemDrive%\Common_Scripts" "%ProgramData%\mobilmir.ru\Common_Scripts"
	) ELSE MKDIR "%ProgramData%\mobilmir.ru\Common_Scripts"
    )
)
(
    "%utilsdir%7za.exe" x -r -aoa "%~dpn0.7z" -o"%ProgramData%\mobilmir.ru\Common_Scripts" || %ErrorCmd%
    %windir%\System32\compact.exe /C /EXE:LZX /S:"%ProgramData%\mobilmir.ru\Common_Scripts" /I /Q || %windir%\System32\compact.exe /C /S:"%ProgramData%\mobilmir.ru\Common_Scripts" /I /Q
    rem "%utilsdir%xln.exe" -n "%ProgramData%\mobilmir.ru\Common_Scripts" "%SystemDrive%\Common_Scripts"
    
    SET "PATH=%PATH%;%ProgramData%\mobilmir.ru\Common_Scripts"
    "%utilsdir%AutoHotkey.exe" "%utilsdir%pathman.ahk" /as "%ProgramData%\mobilmir.ru\Common_Scripts"

    FOR %%A IN (log pwd) DO (
	FTYPE %%~A_file="%ProgramData%\mobilmir.ru\Common_Scripts\open_file.ahk" "%%1"
	ASSOC .%%~A=%%~A_file
    )
)
EXIT /B %ErrorPresence%
