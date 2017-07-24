@(REM coding:CP866
IF NOT DEFINED SysUtilsDir SET "SysUtilsDir=%SystemDrive%\SysUtils"
IF NOT EXIST "%utilsdir%7za.exe" SET "utilsdir=%~dp0..\..\..\PreInstalled\utils\"
)
IF NOT DEFINED pathString SET "pathString=%SysUtilsDir%\gnupg\pub"
(
SET "PATH=%PATH%;%pathString%"
"%utilsdir%7za.exe" x -r -aoa -o"%SysUtilsDir%" "%~dpn0.7z"

IF "%SysUtilsDelaySettings%"=="1" EXIT /B
REM Adding DLLs and CMDs to %PATH%
"%utilsdir%pathman.exe" /as "%pathString%"
)
