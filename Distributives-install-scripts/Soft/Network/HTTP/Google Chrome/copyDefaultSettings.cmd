@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || EXIT /B
    IF NOT DEFINED exe7z CALL :RunFromConfig "_Scripts\find7zexe.cmd" || CALL :SetFirstExistingExe exe7z "%~dp0..\..\PreInstalled\utils\7za.exe" || EXIT /B
    IF NOT DEFINED sedexe SET "pathAppendSubpath=libs" & CALL :RunFromConfig "_Scripts\find_exe.cmd" sedexe "%SystemDrive%\SysUtils\sed.exe" || CALL :SetFirstExistingExe sedexe "%SystemDrive%\SysUtils\sed.exe" || EXIT /B
    IF NOT DEFINED configDir CALL :findconfigDir

    IF DEFINED ProgramFiles^(x86^) IF EXIST "%ProgramFiles(x86)%\Google\Chrome\Application\*" SET "progfilesChrome=%ProgramFiles(x86)%"
    IF NOT DEFINED progfilesChrome SET "progfilesChrome=%ProgramFiles%"
)
(
    IF NOT EXIST "%progfilesChrome%\Google\Chrome\Application\Chrome.exe" EXIT /B 2
    FOR /D %%I IN ("%progfilesChrome%\Google\Chrome\Application\*") DO RD /S /Q "%%~I\default_apps"
    %exe7z% x -aoa -y -o"%progfilesChrome%" -- "%DefaultsSource%" "Google\Chrome\Application"
    IF DEFINED sedexe PUSHD "%progfilesChrome%\Google\Chrome\Application" && (
	%sedexe% -i "s/{ProgramFiles}/%progfilesChrome:\=\\\\%/" "%progfilesChrome%\Google\Chrome\Application\master_preferences"
	POPD
    )
EXIT /B
)
:RunFromConfig
IF NOT DEFINED configDir CALL :findconfigDir
(
    IF "%~x1"==".cmd" (
        CALL "%configDir%"%*
    ) ELSE "%configDir%"%*
    EXIT /B
)
:SetFirstExistingExe <varname> <path1> <path2> <...>
(
    IF EXIST %2 (
        SET %1=%2
        EXIT /B
    )
    IF "%~3"=="" EXIT /B 1
    SHIFT /2
    GOTO :SetFirstExistingExe
)
:findconfigDir
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
(
    CALL :GetDir configDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
