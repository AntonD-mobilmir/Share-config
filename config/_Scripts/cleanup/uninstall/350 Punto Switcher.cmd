@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
)
IF EXIST "%ProgramFiles32%\Yandex\Punto Switcher\punto.exe" IF EXIST "%SoftSourceDir%\Keyboard Tools\Punto Switcher\*.exe" (
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Keyboard Tools\Punto Switcher\install.cmd"
    ECHO %DATE% %TIME% Удаление Punto Switcher
    %AutohotkeyExe% "%SoftSourceDir%\Keyboard Tools\Punto Switcher\uninstall.ahk"
)
