@(REM coding:CP866
IF NOT DEFINED SysUtilsDir CALL "%~dp0..\_init.cmd"
IF NOT DEFINED pathString SET "pathString=%SysUtilsDir%;%SysUtilsDir%\UnxUtils;%SysUtilsDir%\UnxUtils\Uri;%SysUtilsDir%\kliu;%SysUtilsDir%\libs"
)
(
"%utilsdir%7za.exe" x -r -aoa -o"%SysUtilsDir%" "%~dpn0.7z" || %ErrorCmd%
IF NOT "%SysUtilsDelaySettings%"=="1" CALL "%~dp0_finalize.cmd"
)
