@(REM coding:CP866
IF NOT DEFINED SysUtilsDir CALL "%~dp0..\_init.cmd"
IF NOT DEFINED SysUtilsDir SET SysUtilsDir=%SystemDrive%\SysUtils
IF NOT EXIST "%utilsdir%7za.exe" SET utilsdir=%~dp0..\..\utils\
IF NOT DEFINED ErrorCmd (
    SET "ErrorCmd=SET ErrorPresence=1"
    SET "ErrorPresence=0"
)
)
"%utilsdir%7za.exe" x -r -aoa -o"%SysUtilsDir%" "%~dpn0.7z" || %ErrorCmd%
