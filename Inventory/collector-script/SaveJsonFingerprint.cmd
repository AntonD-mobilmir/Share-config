@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

    CALL "%~dp0..\..\config\_Scripts\FindAutoHotkeyExe.cmd" || CALL "%~dp0FindAutoHotkeyExe.cmd" || EXIT /B
    FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
    FOR /f "usebackq tokens=3*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname"`) DO SET "NVHostname=%%~J"

    FOR /F "usebackq tokens=1,2*" %%A IN (`reg.exe query HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1 /v "ClientID" /reg:32`) DO IF "%%A"=="ClientID" SET /A "tvID=%%~C"
    rem /reg:32 won't work on Vista and XP, so fall back
    IF ERRORLEVEL 1 FOR /F "usebackq tokens=1,2*" %%A IN (`reg.exe query HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1 /v "ClientID"`) DO IF "%%A"=="ClientID" SET /A "tvID=%%~C"

    SET "cTime=%TIME::=%"
    SET "cDate=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%"
    MKDIR "%~dp0trello-accounting-update-queue"
    IF EXIST "%~dp0GetFingerprint.ahk" (
	SET GetFingerprintahk="%~dp0GetFingerprint.ahk"
    ) ELSE SET GetFingerprintahk="%~dp0..\..\config\_Scripts\Lib\GetFingerprint.ahk"
    
    SET "destDir=%~dp0trello-accounting-update-queue"
)
SET "destFName=%Hostname% %cDate% %cTime:,=.%"
IF NOT "%~1"=="" (
    IF EXIST "%destDir%" SET "copyDir=%destDir%"
    SET "destDir=%~1"
)
(
    %AutohotkeyExe% "%~dp0..\..\config\_Scripts\Write-trello-id.ahk"
    %AutohotkeyExe% %GetFingerprintahk% "%destDir%\%destFName%.txt" /json "%destDir%\%destFName%.json"
    IF EXIST "%ProgramData%\mobilmir.ru\trello-id.txt" COPY /B /Y "%ProgramData%\mobilmir.ru\trello-id.txt" "%destDir%\%destFName% trello-id.txt"
    IF DEFINED tvID (ECHO %tvID%)>"%destDir%\%destFName% TVID.txt"
    %AutohotkeyExe% %GetFingerprintahk% "%destDir%\%destFName%.txt" /json "%destDir%\%destFName%.json"
    IF DEFINED copyDir XCOPY "%destDir%\%destFName%*.*" "%copyDir%\*.*" /I <NUL
    rem XCOPY "%destDir%\%destFName% trello-id.txt" "%copyDir%\*.*" /I <NUL
EXIT /B
)
