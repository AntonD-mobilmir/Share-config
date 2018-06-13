@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
)
IF EXIST "%ProgramFiles32%\K-Lite Codec Pack\*.*" IF EXIST "%SoftSourceDir%\MultiMedia\Codecs\codecguide.com\K-Lite Codec Pack\*.exe" (
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\MultiMedia\Codecs\_install_common_codecs.cmd"
    ECHO %DATE% %TIME% Удаление K-Lite Codec Pack
    %AutohotkeyExe% "%SoftSourceDir%\MultiMedia\Codecs\codecguide.com\K-Lite Codec Pack\uninstall.ahk"
)
