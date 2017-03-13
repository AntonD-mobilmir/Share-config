@(REM coding:CP866
REM Imports AppLocker policies
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

REM AppLocker rule to deny Microsoft ads: http://winaero.com/blog/stop-windows-10-anniversary-update-from-installing-candy-crush-and-other-unwanted-apps/
REM Running PS1 via cmd: http://stackoverflow.com/a/19111810
REM Running multiple PowerShell commands as powershell.exe arguments: http://stackoverflow.com/a/27912928
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROF	ILE%\Application Data"

rem according to https://technet.microsoft.com/en-us/library/ee791828(v=ws.10).aspx -- %windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -Command "& {&'Import-Module' AppLocker}
%windir%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -Command "& {&'Set-AppLockerPolicy' -XMLPolicy '%~dpn0.xml'}
)
