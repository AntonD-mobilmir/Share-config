@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
)
IF EXIST "%SysWOW64%\Macromed\Flash\*.dll" IF EXIST "%SoftSourceDir%\MultiMedia\Plugins Frameworks Components\Adobe Flash\*.exe" (
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\MultiMedia\Plugins Frameworks Components\Adobe Flash\install.ahk" /noRunInteractiveInstalls /InstallPlugin /InstallActiveX
    ECHO %DATE% %TIME% Удаление Adobe Flash
    CALL "%SoftSourceDir%\MultiMedia\Plugins Frameworks Components\Adobe Flash\uninstaller\uninstall_flash_player.cmd"
)
