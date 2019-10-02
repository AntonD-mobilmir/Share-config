@(REM coding:CP866
    SET "inst32biton64sys="
    REM 32-bit cmd.exe on 64-bit system, 64-bit Program Files
    IF DEFINED ProgramW6432 CALL :CheckExeMT "%ProgramW6432%\Mozilla Thunderbird\thunderbird.exe"
    REM 64-bit cmd.exe on 64-bit system, 32-bit Program Files
    IF NOT DEFINED exeMT IF DEFINED ProgramFiles^(x86^) CALL :CheckExeMT "%ProgramFiles(x86)%\Mozilla Thunderbird\thunderbird.exe" && SET "inst32biton64sys=1"
    REM Default: 32 on 32 or 64 on 64
    IF NOT DEFINED exeMT CALL :CheckExeMT "%ProgramFiles%\Mozilla Thunderbird\thunderbird.exe"
    IF NOT DEFINED exeMT EXIT /B 1
    CALL "%Distributives%\Soft\Network\Mail News\Mozilla Thunderbird\autoupdate.cmd"
EXIT /B
)
:CheckExeMT
(
    IF EXIST "%~1" (
        SET exeMT="%~1"
        EXIT /B 0
    )
    EXIT /B 1
)
