(
@REM coding:OEM
    IF DEFINED PROCESSOR_ARCHITEW6432 (
	"%SystemRoot%\SysNative\cmd.exe" /C %0 %*
	EXIT /B
    )
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
)
FOR /F "usebackq delims=" %%I IN (`DIR /B /O-D "%srcpath%AutoHotkey*_Install.exe"`) DO (
    "%srcpath%%%~I" /s
    rem to extract without associating: /D="%ProgramFiles%\AutoHotkey" /E
    GOTO :ExitInstallFor
)
:ExitInstallFor
FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
(
%AutohotkeyExe% /ErrorStdOut "%~dp0HideStartMenuShortcuts.ahk"
IF NOT DEFINED AutoHotkey_Lib_reentrance SET /A AutoHotkey_Lib_reentrance=1
CALL "%~dp0..\..\PreInstalled\auto\AutoHotkey_Lib.cmd"
FOR %%I IN (%AutohotkeyExe%) DO IF NOT EXIST "%%~dpILib\*" CALL :CheckAndLink "%ProgramFiles(x86)%\AutoHotkey\Lib" "%%~dpILib" || CALL :CheckAndLink "%ProgramFiles%\AutoHotkey\Lib" "%%~dpILib"
EXIT /B
)

:CheckAndLink
(
    IF EXIST "%~1" (
	"%SystemDrive%\SysUtils\xln.exe" -n %1 %2
    ) ELSE EXIT /B 1
    EXIT /B
)
:GetFirstArg
(
    SET %1=%2
EXIT /B
)
