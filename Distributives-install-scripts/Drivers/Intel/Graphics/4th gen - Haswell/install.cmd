@(REM coding:CP866
    SET "srcpath=%~dp0"
    SET "OSCapacity=32"
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OSCapacity=64"
    IF /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET "OSCapacity=64"
    FOR /F "usebackq delims=" %%W IN (`ver`) DO SET "VW=%%~W"

    IF NOT DEFINED AutohotkeyExe CALL :FindAutohotkeyExe || EXIT /B
    CALL :InitRemembering
)
IF "%VW:~0,22%"=="Microsoft Windows XP [" SET "OSCapacity=xp"
(
    FOR /R "%~dp0" %%I IN ("win%OSCapacity%*.zip") DO CALL :RememberIfLatest srczip "%%~fI"
    FOR /R "%~dp0WU\%OSCapacity%-bit" %%I IN ("*.cab") DO CALL :RememberIfLatest srccab "%%~fI"
)
(
    IF DEFINED srccab (
        START "" /B /WAIT %comspec% /C "%srcpath%WU\Install.cmd"
    ) ELSE (
        %AutohotkeyExe% "%srcpath%..\..\install Intel zip.ahk" "%srczip%"
    )
    CALL "%srcpath%..\RemoveFromStartupAndContextMenu.cmd"

    EXIT /B
)

:InitRemembering
(
    SET "LatestDate=0000000000:00"
EXIT /B
)
:RememberIfLatest
(
    SET "CurrentDate=%~t2"
)
(
@rem     01.12.2011 21:29, so reverse date to get correct comparison
    SET "CurrentDate=%CurrentDate:~6,4%%CurrentDate:~3,2%%CurrentDate:~0,2%%CurrentDate:~11%"
)
    IF "%CurrentDate%" GEQ "%LatestDate%" (
	SET "%~1=%~2"
	SET "LatestDate=%CurrentDate%"
    )
EXIT /B

:FindAutohotkeyExe
(
    FOR /F "usebackq tokens=1* delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :CheckAutohotkeyExe %%J
    IF NOT DEFINED AutohotkeyExe GOTO :RunFindAutohotkeyExeScript || EXIT /B
    IF "%~1"=="" EXIT /B
)
(
    %AutohotkeyExe% %*
    EXIT /B
)
:CheckAutohotkeyExe <path>
(
    IF NOT EXIST %1 EXIT /B 1
    SET AutohotkeyExe=%1
    EXIT /B
)
:RunFindAutohotkeyExeScript
    IF NOT DEFINED configDir CALL :findConfigDir || EXIT /B
(
    IF DEFINED configDir CALL "%configDir%_Scripts\FindAutoHotkeyExe.cmd" %*
EXIT /B
)
:findConfigDir
(
    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"

    IF NOT DEFINED DefaultsSource CALL :FirstExisting DefaultsSource "D:\Distributives\config\." "%~d0\Distributives\config\." && GOTO :foundDefaultsSource
    CALL :SplitNetPath host share "%~dp0"
)
(
    CALL :FirstExisting DefaultsSource "\\%host%\profiles$\Share\config\." "\\%host%\Users\Public\Shares\profiles$\Share\config\."
    IF NOT DEFINED DefaultsSource EXIT /B 1
)
:foundDefaultsSource
(
    CALL :GetDir configDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)

:SplitNetPath <hostVar> <shareVar> <path>
@(
    FOR /F "delims=\ tokens=1,2" %%A IN ("%~3") DO (
        IF "%%~A"=="" EXIT /B 1
        IF "%%~B"=="" EXIT /B 2
        SET "%~1=%%~A"
        SET "%~2=%%~B"
        EXIT /B
    )
EXIT /B 3
)
