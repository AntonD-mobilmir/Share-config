@(REM coding:CP866
    IF NOT DEFINED SysUtilsDir CALL "%~dp0_init.cmd"
    IF NOT DEFINED exe7z CALL "%~dp0_init.cmd"
)
(
    IF NOT DEFINED pathString SET "pathString=%SysUtilsDir%\gnupg"
    %exe7z% x -r -aoa -o"%SysUtilsDir%" "%~dpn0.7z" || %ErrorCmd%
    IF NOT "%SysUtilsDelaySettings%"=="1" CALL "%~dp0_finalize.cmd"
)
