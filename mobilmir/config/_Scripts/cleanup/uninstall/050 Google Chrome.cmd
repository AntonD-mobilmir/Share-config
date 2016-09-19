@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF EXIST "%lProgramFiles%\Google\Chrome\Application\chrome.exe" IF EXIST "%SoftSourceDir%\Network\HTTP\Google Chrome\*.msi" (
    ECHO %DATE% %TIME% Удаление Google Chrome
    %AutohotkeyExe% "%SoftSourceDir%\Network\HTTP\Google Chrome\Uninstall.ahk"
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Network\HTTP\Google Chrome\install.ahk"
)
)