@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

rem instgpg is back in PreInstalled\auto since 2017-07-24
rem IF EXIST "%SystemDrive%\SysUtils\gnupg\pub\gpg.exe" SET "instgpg=1"
MOVE /Y "%SystemDrive%\SysUtils" "%SystemDrive%\Windows\Temp\SysUtils_%DATE%_%RANDOM%"
ECHO Running %~dp0prepare.cmd ...
START "Installing PreInstalled" /MIN /WAIT %comspec% /C "%~dp0prepare.cmd"
rem IF DEFINED instgpg START "Installing GnuPG" /MIN %comspec% /C "\\Srv0.office0.mobilmir\Distributives\Soft FOSS\PreInstalled\manual\SysUtils_GPG.cmd"

IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
)
CALL :GetDir ConfigDir "%DefaultsSource%"
(
rem IF NOT DEFINED exe7z CALL "%ConfigDir%_Scripts\find7zexe.cmd"
rem IF NOT DEFINED SetACLexe CALL "%ConfigDir%_Scripts\find_exe.cmd" SetACLexe SetACL.exe
IF NOT DEFINED AutohotkeyExe CALL "%configDir%_Scripts\FindAutoHotkeyExe.cmd"
)
(
ECHO Cleaning non-existing paths from PATH
%AutohotkeyExe% "%configDir%_Scripts\cleanup\settings\cleanup Path var in reg.ahk"
rem FOR /D %%A IN ("%SystemDrive%\Windows\Temp\SysUtils_*.*") DO RD /S /Q "%%~A"
START "�������� ����� SysUtils �� Windows\Temp" /MIN %comspec% /C "%configDir%_Scripts\cleanup\special\RemoveSysutilsFromWinTemp.cmd"
EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
