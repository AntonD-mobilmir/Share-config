@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
)
(
    CALL :CheckAutohotkeyExe && EXIT /B
    rem continuing here if AutoHotkeyScript type isn't defined or specified path points to incorect location
    SET AutohotkeyExe="%ProgramFiles%\AutoHotkey\AutoHotkey.exe"
    CALL :CheckAutohotkeyExe && EXIT /B
    SET AutohotkeyExe="%ProgramFiles(x86)%\AutoHotkey\AutoHotkey.exe"
    CALL :CheckAutohotkeyExe && EXIT /B
    CALL :tryutilsdir
    CALL :CheckAutohotkeyExe && EXIT /B

    REM without these options, autohotkey.exe starts AutoHotkey.ahk, opens help or says
    rem 	Script file not found:
    rem 	D:\Users\*\Documents\AutoHotkey.ahk
    SET "findExeTestExecutionOptions=/ErrorStdOut ."
    CALL "%~dp0find_exe.cmd" AutohotkeyExe AutoHotkey.exe
    REM explicit backup not needed in same scope
    SET "findExeTestExecutionOptions=%findExeTestExecutionOptions%"
EXIT /B
)
:CheckAutohotkeyExe
(
IF NOT DEFINED AutohotkeyExe EXIT /B 1
IF NOT EXIST %AutohotkeyExe% EXIT /B 1
EXIT /B 0
)
:tryutilsdir
(
    IF NOT DEFINED utilsdir CALL "%~dp0FindSoftwareSource.cmd"
    IF NOT DEFINED utilsdir EXIT /B 1
)
(
    SET AutohotkeyExe="%utilsdir%AutoHotkey.exe"
EXIT /B
)
:GetFirstArg
(
    SET %1=%2
EXIT /B
)
