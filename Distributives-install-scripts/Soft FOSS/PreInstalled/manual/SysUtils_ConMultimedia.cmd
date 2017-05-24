@REM coding:OEM
CALL "%~dp0..\..\auto\_init.cmd"
IF NOT DEFINED SysUtilsDir SET SysUtilsDir=%SystemDrive%\SysUtils
IF NOT EXIST "%utilsdir%7za.exe" SET utilsdir=%~dp0..\utils\
IF NOT DEFINED pathString SET pathString=%SysUtilsDir%
SET PATH=%PATH%;%pathString%

"%utilsdir%7za.exe" x -r -aoa -o"%SysUtilsDir%" "%~dpn0.7z"

REM Adding DLLs and CMDs to %PATH%
"%utilsdir%pathman.exe" /as "%pathString%"
