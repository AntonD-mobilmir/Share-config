@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF NOT DEFINED ProgramFiles32 CALL "%~dp0..\uninstall_soft_init.cmd"
)
IF EXIST "%ProgramFiles32%\Skype" IF EXIST "%SoftSourceDir%\Network\Chat Messengers\Skype\*.msi" (
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Network\Chat Messengers\Skype\install.cmd"
    ECHO %DATE% %TIME% Удаление Skype
    CALL "%SoftSourceDir%\Network\Chat Messengers\Skype\Uninstall.cmd"
)
