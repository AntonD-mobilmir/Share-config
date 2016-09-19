@REM coding:CP866
@REM by LogicDaemon <www.logicdaemon.ru>
@REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
GOTO :SkipGetFirstArg
:GetFirstArg
    SET %1=%2
EXIT /B
:SkipGetFirstArg

IF DEFINED AutohotkeyExe IF EXIST %AutohotkeyExe% EXIT /B 0
rem continuing here if AutoHotkeyScript isn't defined or specified path points to incorect location

SET AutohotkeyExe="%ProgramFiles%\AutoHotkey\AutoHotkey.exe"
IF NOT EXIST %AutohotkeyExe% SET AutohotkeyExe="%ProgramFiles(x86)%\AutoHotkey\AutoHotkey.exe"
IF NOT EXIST %AutohotkeyExe% CALL :tryutilsdir
IF NOT EXIST %AutohotkeyExe% EXIT /B 1
EXIT /B 0

:tryutilsdir
    IF NOT DEFINED utilsdir CALL "%~dp0FindSoftwareSource.cmd"
    SET AutohotkeyExe="%utilsdir%AutoHotkey.exe"
EXIT /B
