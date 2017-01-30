@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    SET "ChromeInstSubpath=Google\Chrome\Application"
    CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || EXIT /B
)
CALL :GetDir ConfigDir "%DefaultsSource%"
(
    IF NOT DEFINED exe7z CALL "%ConfigDir%_Scripts\find7zexe.cmd" || EXIT /B
    IF NOT DEFINED sedexe CALL "%ConfigDir%_Scripts\find_exe.cmd" sedexe sed.exe "%SystemDrive%\SysUtils\sed.exe"

    SET "lProgramFiles=%ProgramFiles%"
    IF DEFINED ProgramFiles^(x86^) IF EXIST "%ProgramFiles(x86)%\%ChromeInstSubpath%\*" SET "lProgramFiles=%ProgramFiles(x86)%"
)
(
CALL :AppendLibsPath %sedexe%
SET "ChromeInstPath=%lProgramFiles%\%ChromeInstSubpath%"
)
(
    IF NOT EXIST "%ChromeInstPath%\Chrome.exe" EXIT /B 2
    FOR /D %%I IN ("%ChromeInstPath%\*") DO RD /S /Q "%%~I\default_apps"
    %exe7z% x -aoa -y -o"%lProgramFiles%" -- "%DefaultsSource%" "%ChromeInstSubpath%"
    IF DEFINED sedexe PUSHD "%ChromeInstPath%" && (
	CALL :AppendLibsPath %sedexe%
	%sedexe% -i "s/{ProgramFiles}/%lProgramFiles:\=\\\\%/" "%ChromeInstPath%\master_preferences"
	POPD
    )
EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
:AppendLibsPath <exe-path>
(
    REM workaround for case if initial install, if install started before the path is added to registry
    SET "PATH=%PATH%;%~dp1libs"
EXIT /B
)
