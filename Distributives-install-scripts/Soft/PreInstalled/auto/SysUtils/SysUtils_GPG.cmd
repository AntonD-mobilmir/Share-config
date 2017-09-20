@(REM coding:CP866
IF NOT DEFINED SysUtilsDir CALL "%~dp0_init.cmd"
)
(
IF NOT DEFINED pathString SET "pathString=%SysUtilsDir%\gnupg\pub"
"%utilsdir%7za.exe" x -r -aoa -o"%SysUtilsDir%" "%~dpn0.7z"
IF NOT "%SysUtilsDelaySettings%"=="1" CALL "%~dp0_finalize.cmd"
)
