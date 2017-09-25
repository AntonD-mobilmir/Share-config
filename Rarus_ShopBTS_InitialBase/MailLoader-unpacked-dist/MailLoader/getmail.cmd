@(REM coding:CP866
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
%SystemRoot%\System32\schtasks.exe /Run /TN mobilmir.ru\stunnel

SET "ExtractDest=d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\unpacked"
SET "MoveDest=d:\1S\Rarus\ShopBTS\Exchange"
SET "SignedFilesDir=d:\1S\Rarus\ShopBTS\Exchange\ExtForms"

SET "RecvDir=d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\received"
SET "RecvBakDir=d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\received.bak"
SET "AttDir=d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\attachments"
SET "MonDir=d:\Users\Public\Documents\Рарус"

IF NOT DEFINED gpgexe IF EXIST "%SystemDrive%\SysUtils\gnupg\gpg.exe" ( SET gpgexe="%SystemDrive%\SysUtils\gnupg\gpg.exe" ) ELSE SET gpgexe="%SystemDrive%\SysUtils\gnupg\pub\gpg.exe"
SET "GNUPGHOME=%~dp0gnupg"
SET configxml="%~dp0config-localhost.xml"

SET "maxLogSize=1048576"

SET uud32winexe="%~dp0uud32win.exe"
SET popclientexe="%~dp0popclient.exe"

DEL /F "d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\getmail.lastrun.*.log" 2>NUL

SET "updateInstallScript=\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\MailLoader\install.cmd"
SET "updateDist=\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\MailLoader\dist.7z"
SET "verFile=%~dpn0_dist_ver.txt"
SET "verCheckFile=%~dpn0_dist_ver.check.log"

IF NOT DEFINED configDir CALL :GetConfigDir
rem IF NOT DEFINED exe7z SET "exe7z=%~dp0..\bin\7za.exe"
)
(
IF NOT DEFINED exe7z SET "PATH=%PATH%;%~dp0..\bin" & CALL "%configDir%_Scripts\find7zexe.cmd"
FOR %%A IN ("%verFile%") DO FOR /F %%B IN ("%%~tA") DO SET "dateVerCheck=%%~tA"
rem 02.05.2017 09:38 -- only compare date component
)
(
    IF NOT "%dateVerCheck%"=="%DATE%" (
	IF EXIST "%updateDist%" FOR %%A IN ("%updateDist%") DO (
	    FOR /F "usebackq delims=" %%B IN ("%verFile%") DO (
		IF NOT "%%~tA"=="%%~B" (ECHO Starting "%updateInstallScript%">>"%verCheckFile%") & SET "RunInteractiveInstalls=0" & ( CALL "%updateInstallScript%" > "%~dp0autoupdate.log" 2>&1 ) & EXIT /B
		REM Only first line
		(ECHO update checked %DATE% %TIME%)>"%verCheckFile%"
		GOTO :ExitForUpdateCheck
	    )
	)
    )
)
:ExitForUpdateCheck
(
    IF NOT EXIST "%SignedFilesDir%" MKDIR "%SignedFilesDir%"
    IF NOT EXIST "%RecvDir%" MKDIR "%RecvDir%"
    IF NOT EXIST "%RecvBakDir%" MKDIR "%RecvBakDir%"
    IF NOT EXIST "%MonDir%" MKDIR "%MonDir%"
    IF EXIST "%MonDir%" IF NOT EXIST "%MonDir%\*.*" FOR %%A IN ("%MonDir%") DO MOVE "%%~A" "%%~dpnA-%RANDOM%%%~xA" ||EXIT /B
    
    FOR %%A IN (%configxml%) DO IF NOT EXIST %%A (SET "RecheckConfigXML=1") ELSE FOR %%B IN ("d:\1S\Rarus\ShopBTS\ExtForms\post\sendemail.cfg") DO ECHO %%A: %%~tA / %%B: %%~tB & IF NOT "%%~tA"=="%%~tB" SET "RecheckConfigXML=1"
    IF DEFINED RecheckConfigXML CALL :RecheckConfigXML
    IF NOT EXIST %configxml% ECHO %DATE% %TIME% %configxml% не существует!& EXIT /B
    ECHO %DATE% %TIME% Проверка или завершение повисшего popclient.exe
    %SystemRoot%\System32\taskkill.exe /F /IM popclient.exe && EXIT /B
    REM Если ошибки нет, popclient.exe был убит. В этом случае продолжает работать пакетный файл, который запустил только что прибитый popclient.exe, значит этот процесс [который убил] надо завершить.
    CALL :CheckSizeRotateLogs "%~dp0POPTrace.txt" "%~dp0unpacked-archives.log"
    DEL /Q "%~dp0system\*.*"
)
(
    ECHO %DATE% %TIME% Запуск popclient.exe, см. лог в POPTrace.txt
    ECHO %DATE% %TIME%>>"%~dp0POPTrace.txt"
    rem start нужен, чтобы cmd.exe не задавал глупый вопрос, прервать ли выполнение пакетного файла, если popclient.exe будет убит через TASKKILL
    CIPHER /E %configxml%
    START "" /B /WAIT %popclientexe% -configfile %configxml%
)
IF EXIST "%RecvDir%\*.txt" (
    ECHO %DATE% %TIME% Извлечение вложений из писем "%RecvDir%\*.txt"
    FOR %%I IN ("%RecvDir%\*.txt") DO (
	ECHO 	%%~I
	%uud32winexe% /OutDir="%AttDir%" /Extract /Logfile="%RecvBakDir%\%%~nxI.uud32win.log" "%%~I"
	REM uud32win.exe returns -1 even when extraction was successfull, can't handle errors
    )
) ELSE (
    ECHO Нет писем в "%RecvDir%\*.txt", вложения извлекать не надо.
)
IF EXIST "%AttDir%\*.7z" (
    ECHO %DATE% %TIME% Распаковка архивов "%AttDir%\*.7z"
    ( ECHO %DATE% %TIME%)>>"%~dp0unpacked-archives.log"
    FOR %%I IN ("%AttDir%\*.7z") DO (
	ECHO 	%%~I
	%exe7z% x -aoa -o"%ExtractDest%" -- "%%~I" && ( ECHO %%~nI)>>"%~dp0unpacked-archives.log" && DEL "%%~I"
    )
) ELSE (
    ECHO Архивов в %AttDir%\*.7z нет
)
(
    ECHO %DATE% %TIME% У uud32win.exe есть секунда, чтобы завершиться по-хорошему, затем процесс прибивается
    %SystemRoot%\System32\PING.exe -n 2 -w 1 localhost>NUL
    %SystemRoot%\System32\taskkill.exe /F /IM uud32win.exe
)
(
    ECHO %DATE% %TIME% Подчистка
    IF EXIST "%AttDir%\file01.txt" DEL "%AttDir%\file01.txt"
    IF EXIST "%AttDir%\*.*" (
	FOR %%A IN ("%AttDir%\*.sig") DO %gpgexe% --homedir "%GNUPGHOME%" --keyserver-options no-auto-key-retrieve --verify "%%~A" && (
	    ECHO Y|MOVE /Y "%%~A" "%SignedFilesDir%\%%~nxA"
	    CALL :TryUnpack "%%~dpnA" "%SignedFilesDir%" || ( ECHO Y| MOVE /Y "%%~dpnA" "%SignedFilesDir%\%%~nA" )
	)
	FOR %%A IN ("%AttDir%\*.*") DO ECHO.|MOVE "%%~A" "%MonDir%\%%~nxA"
    )
    FOR %%I IN ("%RecvDir%\*") DO (
	REM Can't do this immediately after deattaching, because uud32win.exe keeps file opened even after batch flow continues
	IF DEFINED RecvBakDir (
	    MOVE /Y "%%~I" "%RecvBakDir%\"
	) ELSE DEL /F /Q "%%~I"
    )
    
    FOR %%I IN ("%ExtractDest%\TS_*.txt") DO (
	ECHO Moving "%%~nxI" to MoveDest
	MOVE /Y "%%~I" "%MoveDest%\" || EXIT /B
    )
    
    FOR %%I IN ("%ExtractDest%\*") DO ECHO Moving "%%~I" to Rarus-Exchange Incoming& MOVE /Y "%%~I" "%MonDir%\"
    DEL /F /Q "%RecvBakDir%\*.*"
    EXIT /B
)
:CheckSizeRotateLogs
(
    FOR %%A IN (%*) DO IF %%~zA GEQ %maxLogSize% MOVE /Y "%%~A" "%%~A.bak"
    EXIT /B
)
:TryUnpack <archive> <dest>
(
    IF "%~x1"==".7z" (
	%exe7z% x -aoa -o%2 -- %1
    ) ELSE EXIT /B 1
)
:RecheckConfigXML
IF NOT DEFINED configDir CALL :GetConfigDir
IF NOT DEFINED AutohotkeyExe CALL "%configDir%_Scripts\FindAutoHotkeyExe.cmd"
(
    %AutohotkeyExe% /ErrorStdOut "%~dp0fill_config-localhost.template.xml_from_sendemail.cfg.ahk"
    EXIT /B
)
:GetConfigDir
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
CALL :GetDir configDir "%DefaultsSource%"
(
rem IF NOT DEFINED exe7z CALL "%configDir%_Scripts\find7zexe.cmd"
rem IF NOT DEFINED SetACLexe CALL "%configDir%_Scripts\find_exe.cmd" SetACLexe SetACL.exe
EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
