@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF NOT DEFINED AutohotkeyExe FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
)
IF NOT EXIST %AutohotkeyExe% CALL "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\FindAutoHotkeyExe.cmd"
%AutohotkeyExe% "%srcpath%..\..\install Intel zip.ahk" "%srcpath%chipset*.zip"
EXIT /B

:GetFirstArg
(
    SET %1=%2
EXIT /B
)
