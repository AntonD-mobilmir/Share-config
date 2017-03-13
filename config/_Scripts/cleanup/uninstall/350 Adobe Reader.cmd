@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF EXIST "%lProgramFiles%\Adobe\Reader 11.0\Reader\AcroRd32.exe" IF EXIST "%SoftSourceDir%\Office Text Publishing\PDF\Adobe Reader\*.msi" (
    ECHO %DATE% %TIME% Удаление Adobe Reader
    %AutohotkeyExe% "%SoftSourceDir%\Office Text Publishing\PDF\Adobe Reader\uninstall.ahk"

    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Office Text Publishing\PDF\Adobe Reader\install.cmd"
)
)
