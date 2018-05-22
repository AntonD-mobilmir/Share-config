@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT DEFINED ProgramFiles32 CALL "%~dp0..\uninstall_soft_init.cmd"
)
FOR %%A IN ("%ProgramFiles32%" "%ProgramFiles64%") DO IF EXIST "%%~A\Mozilla Firefox\firefox.exe" IF EXIST "%SoftSourceDir%\Network\HTTP\Mozilla FireFox\*.exe" (
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Network\HTTP\Mozilla FireFox\install.cmd"
    ECHO %DATE% %TIME% Удаление Mozilla Firefox
    TASKKILL /F /IM firefox.exe
    %AutohotkeyExe% "%SoftSourceDir%\Network\HTTP\Mozilla FireFox\uninstall.ahk"
)
