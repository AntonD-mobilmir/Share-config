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
)
FOR /F "usebackq delims=" %%I IN (`DIR /B /O-D "%srcpath%AutoHotkey*_Install.exe"`) DO (
    "%srcpath%%%~I" /s
    rem to extract without associating: /D="%ProgramFiles%\AutoHotkey" /E
    GOTO :ExitForFindInstaller
)
:ExitForFindInstaller
(
FOR /F "usebackq tokens=2 delims==" %%I IN (`FTYPE AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
)
(
CALL :XPFixACL %AutohotkeyExe%
REM Hiding shortcuts
%AutohotkeyExe% /ErrorStdOut "%~dp0HideStartMenuShortcuts.ahk"
IF NOT DEFINED AutoHotkey_Lib_reentrance (
    SET /A "AutoHotkey_Lib_reentrance=1"
    CALL "%~dp0..\..\PreInstalled\auto\AutoHotkey_Lib.cmd"
)
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
:XPFixACL
(
    REM On Windows XP, permissions are broken after install for some reson: only admins have AutoHotkey.exe access
    FOR /F "usebackq delims=" %%W IN (`ver`) DO SET "VW=%%W"
)
(
    IF NOT "%VW:~0,22%"=="Microsoft Windows XP [" EXIT /B
    %SetACLexe% -on "%~dp1" -ot file -rec cont_obj -actn rstchldrn -rst dacl -actn setowner -ownr "S-1-5-32-544;s:y" -ignoreerr -silent
    IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 (
	REM there is no icacls.exe cacls on XP
	%SystemRoot%\System32\cacls.exe %1 /e /g Everyone:r
	%SystemRoot%\System32\cacls.exe %1 /e /g Все:r
    )
EXIT /B
)
