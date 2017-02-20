@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "policyArchivePrefix=%~dp0GroupPolicy.DenyExecuteRemovables"
)
(
CALL "%~dp0..\find7zexe.cmd"
SET "System32=%SystemRoot%\System32"
IF EXIST "%SystemRoot%\SysNative\cmd.exe" SET "System32=%SystemRoot%\SysNative"
rem via https://social.technet.microsoft.com/Forums/windows/en-US/2030e62e-a60d-442a-8455-647b569caffb/export-import-local-group-policy-objects?forum=itproxpsp

CALL "%~dp0..\CheckWinVer.cmd" 10 || CALL :SetPolicyArchiveSuffix
)
(
%exe7z% x -aoa -x!gpt.ini -o"%System32%\GroupPolicy" "%policyArchivePrefix%%policyArchiveSuffix%.7z" || EXIT /B
"%System32%\gpupdate.exe" /force
EXIT /B
)
:SetPolicyArchiveSuffix
(
IF EXIST "%policyArchivePrefix%.%WinVerNum:~0,3%.7z" SET "policyArchiveSuffix=.%WinVerNum:~0,3%"
EXIT /B
)
