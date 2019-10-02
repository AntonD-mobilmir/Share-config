@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
rem IF EXIST "%DistSourceDir%\Soft com freeware\MultiMedia\Plugins Frameworks Components\Adobe Flash\*.exe"
)
IF EXIST "%SysWOW64%\Macromed\Flash\*.dll"  (
rem     CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%DistSourceDir%\Soft com freeware\MultiMedia\Plugins Frameworks Components\Adobe Flash\install.ahk" /noRunInteractiveInstalls /InstallPlugin /InstallActiveX
    ECHO %DATE% %TIME% Удаление Adobe Flash
    CALL "%DistSourceDir%\Soft com freeware\MultiMedia\Plugins Frameworks Components\Adobe Flash\uninstaller\uninstall_flash_player.cmd"
    DEL "%SysWOW64%\Macromed\Flash\*.log"
    RD "%SysWOW64%\Macromed\Flash"
    RD "%SysWOW64%\Macromed\Temp"
    RD "%SysWOW64%\Macromed"
)
