@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF DEFINED PROCESSOR_ARCHITEW6432 IF NOT DEFINED AutoHotkeyInstallRestart (
	SET "AutoHotkeyInstallRestart=1"
	"%SystemRoot%\SysNative\cmd.exe" /C %0 %*
	EXIT /B
    )
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    CALL :FindAutohotkeyExe
)
(
    IF DEFINED AutohotkeyExe FOR %%A IN (%AutohotkeyExe%) DO (
	ECHO Y|DEL "%%~dpA*.bak"
	CALL :UnlockByMoving "%%~A" "%%~tA %RANDOM%.bak"
    )
    FOR /F "usebackq delims=" %%I IN (`DIR /B /O-D "%srcpath%AutoHotkey_*_setup.exe"`) DO (
	"%srcpath%%%~I" /s
	rem to extract without associating: /D="%ProgramFiles%\AutoHotkey" /E
	CALL :FindAutohotkeyExe && GOTO :InstalledSuccessfully
    )
)
:InstalledSuccessfully
(
    IF DEFINED AutohotkeyExe FOR %%A IN (%AutohotkeyExe%) DO ECHO Y|DEL "%%~dpA*.bak"
    REM Hiding shortcuts
    %AutohotkeyExe% /ErrorStdOut "%~dp0HideStartMenuShortcuts.ahk"
    REM unpacking Lib
    IF NOT DEFINED AutoHotkey_Lib_reentrance (
        SET /A "AutoHotkey_Lib_reentrance=1"
        CALL "%~dp0..\..\PreInstalled\auto\AutoHotkey_Lib.cmd"
)
EXIT /B
)
:FindAutohotkeyExe
(
FOR /F "usebackq tokens=2 delims==" %%I IN (`FTYPE AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
EXIT /B
)
:GetFirstArg
(
    SET %1=%2
EXIT /B
)
:UnlockByMoving <path> <suffix>
(
    IF NOT EXIST %1 EXIT /B 1
    SET "suffix=%~2"
)
SET suffix=%suffix::=%
(
    rem create non-locked copy for the case AutohotkeyExe is currently running
    MOVE /Y %1 "%~1.%suffix%" && COPY /B "%~1.%suffix%" %1 || EXIT /B
    rem try to remove it right away in case it wasn't really locked
    DEL "%~1.%suffix%"
    rem exit without error even if file can't be deleted, since there were no unlock errors [checked previously]
EXIT /B 0
)
