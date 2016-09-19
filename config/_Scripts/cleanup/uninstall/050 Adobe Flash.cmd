@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF EXIST "%SysWOW64%\Macromed\Flash\*.dll" IF EXIST "%SoftSourceDir%\MultiMedia\Plugins Frameworks Components\Adobe Flash\*.exe" (
    ECHO %DATE% %TIME% Удаление Adobe Reader
    TASKKILL /F /IM AcroRd32.exe
    CALL "%SoftSourceDir%\MultiMedia\Plugins Frameworks Components\Adobe Flash\uninstaller\uninstall_flash_player.cmd"
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\MultiMedia\Plugins Frameworks Components\Adobe Flash\install.ahk" /noRunInteractiveInstalls /InstallPlugin /InstallActiveX

)
)
