@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF DEFINED AutohotkeyExe GOTO :SkipGetFirstArg
FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
GOTO :SkipGetFirstArg
:GetFirstArg
    SET %1=%2
EXIT /B
:SkipGetFirstArg
IF NOT DEFINED AutohotkeyExe SET AutohotkeyExe="autohotkey.exe"
)
IF NOT EXIST %AutohotkeyExe% CALL "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\FindAutoHotkeyExe.cmd"
rem %AutohotkeyExe% "%srcpath%..\..\install Intel zip.ahk" "%srcpath%8, 9, C220, C610 Series\Intel(R)_USB_3.0_eXtensible_Host_Controller_Driver_3.0.1.41.zip"
%AutohotkeyExe% "%srcpath%..\..\install Intel zip.ahk" "%srcpath%8, 9, 100, C220, C610\*.zip"
