@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
GOTO :SkipGetFirstArg
:GetFirstArg
    SET %1=%2
EXIT /B
:SkipGetFirstArg
IF NOT DEFINED logfile SET logfile="%~dp0..\logs\%~n0.log"
)
(
%AutohotkeyExe% "%~dp0unpack subdirs.ahk" %* >>%logfile% 2>&1
%AutohotkeyExe% "%~dp0Delete Empty Subdirs.ahk" %* >>%logfile% 2>&1
%AutohotkeyExe% "%~dp0archive.ahk" %* >>%logfile% 2>&1
)
