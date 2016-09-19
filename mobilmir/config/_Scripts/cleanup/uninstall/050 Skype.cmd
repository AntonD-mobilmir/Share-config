@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF EXIST "%lProgramFiles%\Skype" IF EXIST "%SoftSourceDir%\Network\Chat Messengers\Skype\*.msi" (
    ECHO %DATE% %TIME% Удаление Skype
    CALL "%SoftSourceDir%\Network\Chat Messengers\Skype\Uninstall.cmd"

    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Network\Chat Messengers\Skype\install.cmd"
)

)
