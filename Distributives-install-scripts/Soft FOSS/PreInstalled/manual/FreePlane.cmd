(
@REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED utilsdir SET "utilsdir=%~dp0..\..\..\Soft\PreInstalled\utils\"
SET "UIDCreatorOwner=S-1-3-0;s:y"

SET "dest=%LOCALAPPDATA%\Programs"
)
(
IF NOT EXIST "%dest%" MKDIR "%dest%"
"%utilsdir%7za.exe" x -r -aoa -o"%dest%\%~n0" -- "%srcpath%%~n0.7z"
"%SystemDrive%\SysUtils\SetACL.exe" -on "%dest%\%~n0" -ot file -actn ace -ace "n:%UIDCreatorOwner%;p:read_ex;i:so,sc;m:set;w:dacl"
START "" /B /WAIT /D "%dest%\%~n0" /I %comspec% /C "%dest%\%~n0\Install.cmd"
)
