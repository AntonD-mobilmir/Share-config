@(REM coding:CP866
REM Template to install preinstalled and working-without-install software
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF "%utilsdir%"=="" SET "utilsdir=%~dp0..\utils\"
SET "lProgramFiles=%ProgramFiles%"
IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"
)
(
IF NOT EXIST "%lProgramFiles%\%~n0" MKDIR "%lProgramFiles%\%~n0"
"%utilsdir%7za.exe" x -r -aoa "%srcpath%%~n0.7z" -o"%lProgramFiles%\%~n0"
"%SystemRoot%\System32\compact.exe" /C /S:"%lProgramFiles%\%~n0" /I /Q /EXE:LZX || "%SystemRoot%\System32\compact.exe" /C /S:"%lProgramFiles%\%~n0" /I /Q
)
