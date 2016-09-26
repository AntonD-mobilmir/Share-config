(
    @REM coding:OEM
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
    SET ChromeInstSubpath=Google\Chrome\Application
)
(
    IF NOT DEFINED DefaultsSource EXIT /B
    SET lProgramFiles=%ProgramFiles%
    IF DEFINED ProgramFiles^(x86^) IF EXIST "%ProgramFiles(x86)%\%ChromeInstSubpath%\*" SET "lProgramFiles=%ProgramFiles(x86)%"
    CALL :findexe exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL :findexe exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" || (ECHO  & EXIT /B 32767)
    CALL :findexe sedexe sed.exe c:\SysUtils\UnxUtils\sed.exe
)
SET ChromeInstPath=%lProgramFiles%\%ChromeInstSubpath%
(
    IF NOT EXIST "%ChromeInstPath%\Chrome.exe" EXIT /B 2
    FOR /D %%I IN ("%ChromeInstPath%\*") DO RD /S /Q "%%~I\default_apps"
    %exe7z% x -aoa -y -o"%lProgramFiles%" -- "%DefaultsSource%" "%ChromeInstSubpath%"
    PUSHD "%ChromeInstPath%" && (
	%sedexe% -i "s/{ProgramFiles}/%lProgramFiles:\=\\\\%/" "%ChromeInstPath%\master_preferences"
	POPD
    )
)

EXIT /B

:findexe
    (
    SET locvar=%1
    SET seekforexecfname=%~2
    )
    (
    CALL :testexe %locvar% %2 & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED utilsdir CALL :testexe %locvar% "%utilsdir%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "%srcpath%..\..\..\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    )
    :findexeNextPath
    (
	IF "%~3"=="" GOTO :testexe
	IF EXIST "%~3" FOR %%I IN ("%~3") DO CALL :testexe %locvar% "%%~I" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
	SHIFT /3
    GOTO :findexeNextPath
    )
    :testexe
    (
	IF "%~2"=="" EXIT /B 9009
	IF NOT EXIST "%~dp2" EXIT /B 9009
	"%~2" >NUL 2>&1
	IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
	SET %1=%2
    )
EXIT /B
