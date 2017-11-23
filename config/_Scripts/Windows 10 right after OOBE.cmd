@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

CALL "%~dp0\Security\AppLocker - Deny promoted apps (Win10).cmd"
CALL "%~dp0\cleanup\AppX\Remove All AppX Apps for current user.cmd" /firstlogon
CALL "%~dp0\cleanup\AppX\Remove AppX Apps except allowed.cmd" /quiet
CALL "%~dp0FindAutoHotkeyExe.cmd" "%~dp0cleanup\uninstall\050 OneDrive.ahk"

CALL "%~dp0find7zexe.cmd"
SET "xtmp=%TEMP%\%~n0"
)
(
%exe7z% x -o"%xtmp%" "%~dp0..\Users\Default\AppData\Local\DefaultUserRegistrySettings.7z"
FOR %%A IN ("%xtmp%\*.reg") DO REG IMPORT "%%~A"
RD /S /Q "%xtmp%"
)
