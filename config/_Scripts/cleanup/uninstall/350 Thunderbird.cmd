@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
)
FOR %%A IN ("%ProgramFiles32%" "%ProgramFiles64%") DO IF EXIST "%%~A\Mozilla Thunderbird\thunderbird.exe" IF EXIST "%SoftSourceDir%\Network\Mail News\Mozilla Thunderbird\*.exe" (
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Network\Mail News\Mozilla Thunderbird\install.cmd"
    ECHO %DATE% %TIME% Удаление Mozilla Thunderbird
    TASKKILL /F /IM thunderbird.exe
    %AutohotkeyExe% "%SoftSourceDir%\Network\Mail News\Mozilla Thunderbird\uninstall.ahk"
)
