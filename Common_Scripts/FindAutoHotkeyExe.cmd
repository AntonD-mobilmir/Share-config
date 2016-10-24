@REM coding:OEM

FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
GOTO :SkipGetFirstArg
:GetFirstArg
    SET %1=%2
EXIT /B
:SkipGetFirstArg

IF EXIST %AutohotkeyExe% EXIT /B 0

rem continuing here if AutoHotkeyScript isn't defined or specified path points to incorect location
IF DEFINED utilsdir SET AutohotkeyExe="%utilsdir%AutoHotkey.exe"
IF NOT EXIST %AutohotkeyExe% SET AutohotkeyExe="%ProgramFiles%\AutoHotkey\AutoHotkey.exe"
IF NOT EXIST %AutohotkeyExe% SET AutohotkeyExe="%ProgramFiles(x86)%\AutoHotkey\AutoHotkey.exe"

IF NOT EXIST %AutohotkeyExe% EXIT /B 1
