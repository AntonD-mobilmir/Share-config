@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    
    IF NOT DEFINED ahkOptions IF "%RunInteractiveInstalls%"=="0" SET "ahkOptions=/ErrorStdOut"
    
    CALL "%~dp0..\..\config\_Scripts\FindAutoHotkeyExe.cmd" || CALL "%~dp0FindAutoHotkeyExe.cmd" || CALL :TryAutohotkeyLocals || EXIT /B
    FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
    FOR /f "usebackq tokens=3*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname"`) DO SET "NVHostname=%%~J"
    
    FOR /F "usebackq tokens=1,2*" %%A IN (`reg.exe query HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1 /v "ClientID" /reg:32`) DO IF "%%A"=="ClientID" SET /A "tvID=%%~C"
    rem /reg:32 won't work on Vista and XP, so fall back
    IF ERRORLEVEL 1 FOR /F "usebackq tokens=1,2*" %%A IN (`%SystemRoot%\System32\reg.exe query HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1 /v "ClientID"`) DO IF "%%A"=="ClientID" SET /A "tvID=%%~C"
    
    SET "cTime=%TIME::=%"
    SET "cDate=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%"
    IF NOT EXIST "%ProgramData%\mobilmir.ru\Fingerprint" MKDIR "%ProgramData%\mobilmir.ru\Fingerprint"
    SET "destDir=%ProgramData%\mobilmir.ru\Fingerprint"
    FOR /D %%A IN ("\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Inventory\trello-accounting\update-queue" "%~dp0..\trello-accounting\update-queue" "\\Srv0.office0.mobilmir\profiles$\Share\Inventory\trello-accounting\update-queue") DO IF NOT DEFINED copyDir IF EXIST %%A SET "copyDir=%%~A"
    IF NOT DEFINED copyDir SET "copyDir=%~dp0Fingerprints"
    IF EXIST "%~dp0GetFingerprint.ahk" (
	SET GetFingerprintahk="%~dp0GetFingerprint.ahk"
    ) ELSE SET GetFingerprintahk="%~dp0..\..\config\_Scripts\GetFingerprint.ahk"
)
SET "destFName=%Hostname% %cDate% %cTime:,=.%"
(
    %AutohotkeyExe% %ahkOptions% %GetFingerprintahk% "%destDir%\%destFName%.txt" /json "%destDir%\%destFName%.json" >"%destDir%\%destFName%.log" 2>&1
    FOR %%A IN ("%destDir%\%destFName%.log") DO IF EXIST "%%~A" IF "%%~zA"=="0" DEL "%%~A"
    
    SET "FingerprintChanged=1"
    IF EXIST "%destDir%\%Hostname%.json" (
	(ECHO N|"%SystemRoot%\System32\comp.exe" "%destDir%\%Hostname%.json" "%destDir%\%destFName%.json" 2>NUL)
	IF NOT ERRORLEVEL 1 (
	    REM Отпечатки не отличаются, можно удалить новый и выйти
	    DEL "%destDir%\%destFName%.json"
	    DEL "%destDir%\%destFName%.txt"
	    SET "FingerprintChanged="
	)
	FOR %%A IN ("%destDir%\%Hostname%.json") DO CALL :AppendDateToName "%destDir%\%Hostname%.*" "%%~tA"
    )
    IF DEFINED FingerprintChanged (
	MOVE /Y "%destDir%\%destFName%.json" "%destDir%\%Hostname%.json" 
	MOVE /Y "%destDir%\%destFName%.txt" "%destDir%\%Hostname%.txt" 

	IF EXIST "%~dp0..\..\config\_Scripts\Write-trello-id.ahk" %AutohotkeyExe% %ahkOptions% "%~dp0..\..\config\_Scripts\Write-trello-id.ahk" %Write-trello-id.ahk-params% >"%destDir%\%Hostname% Write-trello-id.log" 2>&1
	FOR %%A IN ("%destDir%\%Hostname% Write-trello-id.log") DO IF EXIST "%%~A" IF "%%~zA"=="0" DEL "%%~A"
    )
    IF DEFINED tvID (ECHO %tvID%)>"%destDir%\%Hostname% TVID.txt"
)
(
    FOR %%A IN ("%copyDir%" %*) DO IF EXIST "%%~A" (
	IF EXIST "%ProgramData%\mobilmir.ru\trello-id.txt" COPY /B /Y "%ProgramData%\mobilmir.ru\trello-id.txt" "%%~A\%Hostname% trello-id.txt"
	XCOPY "%destDir%\%Hostname%.*" "%%~A\" /Y /I <NUL
	XCOPY "%destDir%\%Hostname% *.*" "%%~A\" /Y /I <NUL
    )
EXIT /B
)
:AppendDateToName <mask> <date>
SET "suffix=%~2"
SET "suffix=%suffix::=%"
SET "suffix=%suffix:~6,4%-%suffix:~3,2%-%suffix:~0,2%%suffix:~10%"
(
    FOR %%B IN (%1) DO MOVE /Y "%%~B" "%%~dpnB %suffix%%%~xB"
EXIT /B
)
:TryAutohotkeyLocals
IF NOT DEFINED binDir SET "binDir=%~dp0bin"
FOR %%A IN ("%~dp0AutoHotkey.exe" "%binDir%\AutoHotkey.exe") DO (
    IF EXIST %%A (
	SET AutohotkeyExe="%%~A"
	EXIT /B 0
    )
)
EXIT /B 1
