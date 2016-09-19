@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF EXIST "%lProgramFiles%\Mozilla Thunderbird\thunderbird.exe" IF EXIST "%SoftSourceDir%\Network\Mail News\Mozilla Thunderbird\*.exe" (
    ECHO %DATE% %TIME% Удаление Mozilla Thunderbird
    TASKKILL /F /IM thunderbird.exe
    %AutohotkeyExe% "%SoftSourceDir%\Network\Mail News\Mozilla Thunderbird\uninstall.ahk"

    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Network\Mail News\Mozilla Thunderbird\install.cmd"
)

)
