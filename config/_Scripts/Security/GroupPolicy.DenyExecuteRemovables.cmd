@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
)
(
CALL "%~dp0..\find7zexe.cmd"
SET "System32=%SystemRoot%\System32"
IF EXIST "%SystemRoot%\SysNative\*.*" SET "System32=%SystemRoot%\SysNative"
rem via https://social.technet.microsoft.com/Forums/windows/en-US/2030e62e-a60d-442a-8455-647b569caffb/export-import-local-group-policy-objects?forum=itproxpsp
)
%exe7z% x -aoa -x!gpt.ini -o"%System32%\GroupPolicy" "%~dp0GroupPolicy.DenyExecuteRemovables.7z"
"%System32%\gpupdate.exe" /force
