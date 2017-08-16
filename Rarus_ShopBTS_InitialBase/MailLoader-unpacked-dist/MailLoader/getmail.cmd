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

IF NOT DEFINED gpgexe SET gpgexe="%SystemDrive%\SysUtils\gnupg\pub\gpg.exe"
SET "GNUPGHOME=%~dp0gnupg"

SET "maxLogSize=1048576"

SET uud32winexe="%~dp0uud32win.exe"
SET popclientexe="%~dp0popclient.exe"

DEL /F "d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\getmail.lastrun.*.log"

rem IF NOT DEFINED exe7z SET "exe7z=%~dp0..\bin\7za.exe"
IF NOT DEFINED exe7z SET "PATH=%PATH%;%~dp0..\bin" & CALL "d:\Distributives\config\_Scripts\find7zexe.cmd"

SET "updateInstallScript=\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\MailLoader\install.cmd"
SET "updateDist=\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\MailLoader\dist.7z"
SET "verFile=%~dpn0_dist_ver.txt"
)
(
    FOR %%A IN ("%verFile%") DO FOR /F %%B IN ("%%~tA") DO SET "dateVerCheck=%%~tA"
    IF NOT "%dateVerCheck%"=="%DATE%" (
	FOR %%A IN ("%updateDist%") DO (
	    SET "distVer=%%~tA"
	    FOR /F "usebackq delims=" %%B IN ("%verFile%") DO (
		IF NOT "%%~tA"=="%%~B" SET "runUpdate=1"
	    )
	)
	IF DEFINED runUpdate (
	    SET "RunInteractiveInstalls=0"
	    CALL "%updateInstallScript%"
	    EXIT /B
	)
    )

    IF NOT EXIST "%SignedFilesDir%" MKDIR "%SignedFilesDir%"
    IF NOT EXIST "%RecvDir%" MKDIR "%RecvDir%"
    IF NOT EXIST "%RecvBakDir%" MKDIR "%RecvBakDir%"
    IF NOT EXIST "%MonDir%" MKDIR "%MonDir%"
    IF EXIST "%MonDir%" IF NOT EXIST "%MonDir%\*.*" FOR %%A IN ("%MonDir%") DO MOVE "%%~A" "%%~dpnA-%RANDOM%%%~xA" ||EXIT /B

    ECHO %DATE% %TIME% Проверка или завершение повисшего popclient.exe
    %SystemRoot%\System32\taskkill.exe /F /IM popclient.exe && EXIT /B
    REM Если ошибки нет, popclient.exe был убит. В этом случае продолжает работать пакетный файл, который запустил только что прибитый popclient.exe, значит этот процесс [который убил] надо завершить.
    CALL :CheckSizeRotateLogs "%~dp0POPTrace.txt" "%~dp0unpacked-archives.log"
    DEL /Q "%~dp0system\*.*"
)
(
    ECHO %DATE% %TIME% Запуск popclient.exe, см. лог в POPTrace.txt
    ECHO %DATE% %TIME%>>"%~dp0POPTrace.txt"
    rem start нужен, чтобы cmd.exe не задавал глупый вопрос, прервать ли выполнение пакетного файла, когда popclient.exe будет убит
    CIPHER /E "d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\config-localhost.xml"
    START "" /B /WAIT %popclientexe% -configfile "d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\config-localhost.xml"
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
:WriteoutDistVer
(
    (
	ECHO %distVer%
    ) >"%verFile%"
EXIT /B
)
