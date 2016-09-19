@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd" || (PAUSE & EXIT /B 32767)
MKDIR R:\Rarus
)
CALL :procconfig "%DefaultsSource%" || (PAUSE & EXIT /B 32767)
CALL "%ConfigDir%_Scripts\CheckWinVer.cmd" 6 || GOTO :XP

"%SystemRoot%\System32\schtasks.exe" /Delete /TN "mobilmir\backup_1S_base" /F
"%SystemRoot%\System32\schtasks.exe" /Create /TN "mobilmir.ru\backup_1S_base" /XML "%~dp0Tasks\backup_1S_base.xml" /F
EXIT /B

:XP
(
    %exe7z% x -aoa -o"%SystemRoot%\Tasks" "%srcpath%Tasks.7z" backup_1S_base.job
    "%SystemRoot%\System32\schtasks.exe" /Change /TN backup_1S_base /RU SYSTEM
EXIT /B
)
:procconfig <DefaultsSource>
(
    CALL "%~dp1_Scripts\find7zexe.cmd"
    SET "ConfigDir=%~dp1"
EXIT /B
)
