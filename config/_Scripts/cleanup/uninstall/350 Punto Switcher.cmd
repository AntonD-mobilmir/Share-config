@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF EXIST "%lProgramFiles%\Yandex\Punto Switcher\punto.exe" IF EXIST "%SoftSourceDir%\Keyboard Tools\Punto Switcher\*.exe" (
    ECHO %DATE% %TIME% Удаление Punto Switcher
    %AutohotkeyExe% "%SoftSourceDir%\Keyboard Tools\Punto Switcher\uninstall.ahk"

    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Keyboard Tools\Punto Switcher\install.cmd"
)
)
