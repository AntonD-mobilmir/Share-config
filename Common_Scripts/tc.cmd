REM coding:OEM
SETLOCAL
SET "TCRelPath=Total Commander\TOTALCMD.EXE"
SET "TCDistRelPath=PreInstalled\manual\TotalCommander.cmd"
CALL :FindTCPath || CALL :InstallTC || (
    ECHO TC or distributive not found & PAUSE & EXIT /B 
)
IF "%~1"=="" (
    SET param="%CD%"
) ELSE SET "param=%*"
(
ENDLOCAL
START "" /B "%exeTC%" %param%
EXIT /B
)

:InstallTC
    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
    CALL :GetDir ConfigDir "%DefaultsSource%"
(
    CALL %ConfigDir%_Scripts\FindSoftwareSource.cmd || EXIT /B
    CALL :InstallFirst "%SoftSourceDir%\%TCDistRelPath%" "D:\Distributives\Soft\%TCDistRelPath%" "W:\Distributives\Soft\%TCDistRelPath%" "\\Srv0.office0.mobilmir\Distributives\Soft\%TCDistRelPath%"
    CALL :FindTCPath
    PING 127.0.0.1 -n 3 >NUL
    EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)

:FindTCPath
    IF NOT DEFINED LOCALAPPDATA SET "LOCALAPPDATA=%USERPROFILE%\AppData\Local"
(
    CALL :FindFirstExisting exeTC "%LOCALAPPDATA%\Programs\%TCRelPath%" "%ProgramFiles%\%TCRelPath%" "%ProgramFiles(x86)%\%TCRelPath%"
    EXIT /B
)

:FindFirstExisting <var> <path> <...>
IF EXIST "%~2" (
    SET "%~1=%~2"
    EXIT /B 0
) ELSE (
    IF "%~3"=="" EXIT /B 1
    SHIFT /2
    GOTO :FindFirstExisting
)

:InstallFirst
    CALL :FindFirstExisting cmdTCInst %* || EXIT /B 1
    IF NOT EXIST "%APPDATA%\GHISLER\wincmd.ini" SET "SetUserSettings=1"
    START "" /B /WAIT %comspec% /C "%cmdTCInst%"
EXIT /B 0

:FindAutoHotkeyExe
    FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
    GOTO :SkipGetFirstArg
    :GetFirstArg
	SET %1=%2
    EXIT /B
    :SkipGetFirstArg

    IF EXIST %AutohotkeyExe% EXIT /B 0

    rem continuing here if AutoHotkeyScript isn't defined or specified path points to incorect location
    IF NOT DEFINED utilsdir CALL "%~dp0FindSoftwareSource.cmd"

    SET AutohotkeyExe="%utilsdir%AutoHotkey.exe"
    IF NOT EXIST %AutohotkeyExe% SET AutohotkeyExe="%ProgramFiles%\AutoHotkey\AutoHotkey.exe"
    IF NOT EXIST %AutohotkeyExe% SET AutohotkeyExe="%ProgramFiles(x86)%\AutoHotkey\AutoHotkey.exe"

    IF NOT EXIST %AutohotkeyExe% EXIT /B 1
EXIT /B
