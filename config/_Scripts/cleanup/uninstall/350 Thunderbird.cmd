@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
    SET "uninstallThunderbird="
)
    IF EXIST "%ProgramFiles32%\Mozilla Thunderbird\thunderbird.exe" IF EXIST "%SoftSourceDir%\Network\Mail News\Mozilla Thunderbird\32-bit\*.exe" SET "uninstallThunderbird=1"
    IF "%OSWordSize%"=="64" IF EXIST "%ProgramFiles64%\Mozilla Thunderbird\thunderbird.exe" IF EXIST "%SoftSourceDir%\Network\Mail News\Mozilla Thunderbird\64-bit\*.exe" SET "uninstallThunderbird=1"
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Network\Mail News\Mozilla Thunderbird\install.cmd"
    ECHO %DATE% %TIME% Удаление Mozilla Thunderbird
    TASKKILL /F /IM thunderbird.exe
    %AutohotkeyExe% "%SoftSourceDir%\Network\Mail News\Mozilla Thunderbird\uninstall.ahk"
)
