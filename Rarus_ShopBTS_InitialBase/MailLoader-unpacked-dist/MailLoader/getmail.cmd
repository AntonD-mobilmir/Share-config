@(REM coding:CP866
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
%SystemRoot%\System32\schtasks.exe /Run /TN mobilmir.ru\stunnel

SET "ExtractDest=d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\unpacked"
SET "MoveDest=d:\1S\Rarus\ShopBTS\Exchange"
rem SET "MoveDest2=d:\Exchange\InOperator"

SET "RecvDir=d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\received"
SET "RecvBakDir=d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\received.bak"
SET "AttDir=d:\1S\Rarus\ShopBTS\ExtForms\MailLoader\attachments"
SET "MonDir=d:\Users\Public\Documents\Рарус"

SET uud32winexe="%~dp0uud32win.exe"
SET popclientexe="%~dp0popclient.exe"
rem IF NOT DEFINED exe7z SET "exe7z=%~dp0..\bin\7za.exe"
IF NOT DEFINED exe7z SET "PATH=%PATH%;%~dp0..\bin" & CALL "d:\Distributives\config\_Scripts\find7zexe.cmd"
)
(
    IF NOT EXIST "%RecvDir%" MKDIR "%RecvDir%"
    IF NOT EXIST "%RecvBakDir%" MKDIR "%RecvBakDir%"
    IF NOT EXIST "%MonDir%" MKDIR "%MonDir%"

    ECHO %DATE% %TIME% Проверка или завершение повисшего popclient.exe
    %SystemRoot%\System32\taskkill.exe /F /IM popclient.exe && EXIT /B
    REM Если ошибки нет, popclient.exe был убит. В этом случае продолжает работать пакетный файл, который запустил только что прибитый popclient.exe, значит этот процесс [который убил] надо завершить.
)
(
    ECHO %DATE% %TIME% Запуск popclient.exe, см. лог в POPTrace.txt
    ECHO %DATE% %TIME%>>"%~dp0POPTrace.txt"
    rem start нужен, чтобы cmd.exe не задавал глупый вопрос, прервать ли выполнение пакетного файла, когда popclient.exe будет убит
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
    FOR %%I IN ("%AttDir%\*.7z") DO (
	ECHO 	%%~I
	%exe7z% x -aoa -o"%ExtractDest%" -- "%%~I" && DEL "%%~I"
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
    IF EXIST "%AttDir%\*.*" FOR %%A IN ("%AttDir%\*.*") DO MOVE /Y "%%~A" "%MonDir%\%%~nxA"
    FOR %%I IN ("%RecvDir%\*") DO (
	REM Can't do this immediately after deattaching, because uud32win.exe keeps file opened even after batch flow continues
	IF DEFINED RecvBakDir (
	    MOVE /Y "%%~I" "%RecvBakDir%\"
	) ELSE DEL /F /Q "%%~I"
    )
    
    FOR %%I IN ("%ExtractDest%\TS_*.txt") DO (
	IF DEFINED MoveDest2 (
	    ECHO Moving "%%~nxI" to MoveDest2
	    COPY /B /Y "%%~I" "%%~I-2" && MOVE /Y "%%~I-2" "%MoveDest2%\%%~nxI"
	) || EXIT /B
	ECHO Moving "%%~nxI" to MoveDest
	MOVE /Y "%%~I" "%MoveDest%\" || EXIT /B
    )
    
    FOR %%I IN ("%ExtractDest%\*") DO ECHO Moving "%%~I" to Rarus-Exchange Incoming& MOVE /Y "%%~I" "%MonDir%"
    DEL /F /Q "%RecvBakDir%\*.*"
    EXIT /B
)
