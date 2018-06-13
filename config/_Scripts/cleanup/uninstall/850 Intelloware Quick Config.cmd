@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
)
FOR %%A IN ("%ProgramFiles32%" "%ProgramFiles64%") DO IF EXIST "%%~A\Quick Config\Quick Config.exe" IF EXIST "%SoftSourceDir%\..\Distributives\Soft com freeware\Network\Configuration\Intelloware Quick Config\*.msi" (
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\..\Distributives\Soft com freeware\Network\Configuration\Intelloware Quick Config\install.ahk"
    ECHO %DATE% %TIME% Удаление Intelloware Quick Config
    CALL "%SoftSourceDir%\Network\Configuration\Intelloware Quick Config\uninstall.cmd"
)
