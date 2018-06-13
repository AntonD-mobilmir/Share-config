@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
)
IF EXIST "%SystemDrive%\SysUtils" IF EXIST "%SoftSourceDir%\PreInstalled\auto\SysUtils\*.7z" (
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\PreInstalled\prepare.cmd"
    ECHO %DATE% %TIME% Удаление SysUtils, Common_Scripts и notepad2
    RD /S /Q "%SystemDrive%\SysUtils"
    RD /S /Q "%SystemDrive%\Common_Scripts"
    RD /S /Q "%ProgramData%\mobilmir.ru\Common_Scripts"
    RD /S /Q "%ProgramFiles32%\notepad2"
)
