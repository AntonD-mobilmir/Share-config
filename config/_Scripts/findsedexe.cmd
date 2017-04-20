@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
rem IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
rem IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF NOT DEFINED LOCALAPPDATA SET "LOCALAPPDATA=%USERPROFILE%\AppData\Local"

CALL :findsedexe || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 CALL :unpacksedexe || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
EXIT /B 0

:unpacksedexe
CALL "%~dp0FindSoftwareSource.cmd"
CALL "%~dp0find7zexe.cmd"
SET "PATH=%PATH%;%LOCALAPPDATA%\Programs\SysUtils\libs"
)
%exe7z% x -aoa -o"%LOCALAPPDATA%\Programs\SysUtils" -- "%SoftSourceDir%\PreInstalled\auto\SysUtils\SysUtils_ConEssentials.7z"
:findsedexe
(
CALL "%~dp0find_exe.cmd" sedexe sed.exe "%SystemDrive%\SysUtils\UnxUtils\sed.exe" "%LOCALAPPDATA%\Programs\SysUtils\sed.exe"
EXIT /B
)
