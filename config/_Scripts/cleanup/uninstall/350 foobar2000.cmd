@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF EXIST "%lProgramFiles%\foobar2000\foobar2000.exe" IF EXIST "%SoftSourceDir%\MultiMedia\Players\foobar2000\*.exe" (
    ECHO %DATE% %TIME% Удаление foobar2000
    TASKKILL /F /IM foobar2000.exe
    %AutohotkeyExe% "%SoftSourceDir%\MultiMedia\Players\foobar2000\uninstall.ahk"
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\MultiMedia\Players\foobar2000\install.cmd"
)

)
