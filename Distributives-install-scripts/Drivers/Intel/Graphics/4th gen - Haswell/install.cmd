(
@REM coding:CP866
SET "srcpath=%~dp0"
SET "OSCapacity=32"
IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OSCapacity=64"
IF /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET "OSCapacity=64"
FOR /F "usebackq delims=" %%W IN (`ver`) DO SET "VW=%%~W"
)
(
IF "%VW:~0,22%"=="Microsoft Windows XP [" SET "OSCapacity=xp"

FOR /F "usebackq tokens=2 delims==" %%I IN (`FTYPE AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
IF NOT DEFINED AutohotkeyExe CALL "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\FindAutoHotkeyExe.cmd" || EXIT /B
)
(
CALL :InitRemembering
FOR /R "%~dp0" %%I IN ("win%OSCapacity%*.zip") DO CALL :RememberIfLatest srczip "%%~fI"
FOR /R "%~dp0WU\%OSCapacity%-bit" %%I IN ("*.cab") DO CALL :RememberIfLatest srccab "%%~fI"
)

IF DEFINED srccab (
    START "" /B /WAIT %comspec% /C "%srcpath%WU\Install.cmd"
) ELSE (
    %AutohotkeyExe% "%srcpath%..\..\install Intel zip.ahk" "%srczip%"
)
CALL "%srcpath%..\RemoveFromStartupAndContextMenu.cmd"

EXIT /B

:GetFirstArg
(
    SET %1=%2
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
