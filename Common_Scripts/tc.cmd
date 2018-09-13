@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF NOT DEFINED LOCALAPPDATA IF EXIST "%USERPROFILE%\Local Settings\Application Data" SET "APPDATA=%USERPROFILE%\Local Settings\Application Data"

    IF "%~1"=="/clean" (
        RD /S /Q "%APPDATA%\GHISLER"
        RD /S /Q "%LOCALAPPDATA%\Programs\Total Commander"
        RD "%LOCALAPPDATA%\Programs"
    )

    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"
    IF DEFINED OS64Bit (
	SET "TCRelPath=Total Commander\TOTALCMD64.EXE"
	CALL :FindTCPath || CALL :InstallTC || GOTO :fallback32bit
	GOTO :starttc
    )
:fallback32bit
    SET "TCRelPath=Total Commander\TOTALCMD.EXE"
    CALL :FindTCPath || CALL :InstallTC || (ECHO TC not found, cannot install & PAUSE & EXIT /B)
:starttc
    SET param=%*
    IF NOT DEFINED param SET param="%CD%"
)
(
    ENDLOCAL
    CALL :AddTCPath "%exeTC%"
    START "" /B "%exeTC%" %param%
    EXIT /B
)
:AddTCPath
(
    SET "PATH=%PATH%;%~dp1"
    EXIT /B
)
:InstallTC
(
    SET "TCDistRelPath=PreInstalled\manual\TotalCommander.cmd"
    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
)
    CALL :GetDir ConfigDir "%DefaultsSource%"
    CALL "%ConfigDir%_Scripts\FindSoftwareSource.cmd"
(
    IF DEFINED SoftSourceDir CALL :InstallFirst "%SoftSourceDir%\%TCDistRelPath%" && GOTO :FindTCPath
    CALL :InstallFirst "D:\Distributives\Soft\%TCDistRelPath%" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\%TCDistRelPath%" "\\Srv0.office0.mobilmir\Distributives\Soft\%TCDistRelPath%" && GOTO :FindTCPath
    ECHO Install failed!
    EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
:InstallFirst
    CALL :FindFirstExisting cmdTCInst %* || EXIT /B 1
    IF NOT EXIST "%APPDATA%\GHISLER\wincmd.ini" SET "SetUserSettings=1"
    %comspec% /C "%cmdTCInst%"
EXIT /B 0
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
