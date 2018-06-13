@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
)
IF EXIST "%ProgramFiles32%\FreeVimager\*.*" IF EXIST "%SoftSourceDir%\Graphics\Viewers Managers\FreeVimager\*.exe" (
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Graphics\Viewers Managers\FreeVimager\install.cmd"
    ECHO %DATE% %TIME% Удаление FreeVimager
    TASKKILL /F /IM FreeVimager.exe
    %AutohotkeyExe% "%SoftSourceDir%\Graphics\Viewers Managers\FreeVimager\uninstall.ahk"
)
