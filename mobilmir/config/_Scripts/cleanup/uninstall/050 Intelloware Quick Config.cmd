@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF EXIST "%lProgramFiles%\Quick Config\Quick Config.exe" IF EXIST "%SoftSourceDir%\Network\Configuration\Intelloware Quick Config\*.msi" (
    ECHO %DATE% %TIME% Удаление Intelloware Quick Config
    CALL "%SoftSourceDir%\Network\Configuration\Intelloware Quick Config\uninstall.cmd"

    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Network\Configuration\Intelloware Quick Config\install.ahk"
)

)
