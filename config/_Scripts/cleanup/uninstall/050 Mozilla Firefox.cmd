@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF EXIST "%lProgramFiles%\Mozilla Firefox\firefox.exe" IF EXIST "%SoftSourceDir%\Network\HTTP\Mozilla FireFox\*.exe" (
    ECHO %DATE% %TIME% Удаление Mozilla Firefox
    TASKKILL /F /IM firefox.exe
    %AutohotkeyExe% "%SoftSourceDir%\Network\HTTP\Mozilla FireFox\uninstall.ahk"

    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Network\HTTP\Mozilla FireFox\install.cmd"
)
)
