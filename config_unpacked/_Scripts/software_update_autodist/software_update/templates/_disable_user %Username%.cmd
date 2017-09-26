@(REM coding:CP866
REM шаблон имени файла: префикс_без_пробелов *пробел* имя пользователя (любые символы) "." любое_расширение
REM например: _disable_(Анатолий_Ларионов) Shadow.cmd

REM https://trello.com/c/QhOVYvMX/5-учетные-записи-на-рабочих-станциях
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
    rem  1 | Alias name     Administrators
    rem  2 | Comment        Administrators have complete and unrestricted access to the computer/domain
    rem  3 | 
    rem  4 | Members
    rem  5 | 
    rem  6 | -------------------------------------------------------------------------------
    rem  7 | Administrator
    rem  8 | antic
    rem  9 | Anton.Derbenev
    rem 10 | Install0
    rem 11 | The command completed successfully.

    FOR /F "tokens=1*" %%A IN ("%~n0") DO SET "dUsername=%%~B"

    SET /A "adminCount=-1"
    REM starting with -1 instead of 0 to discount last line, as it may be different per language and OS version.
)
(
    FOR /F "usebackq skip=6 delims=" %%A IN (`%SystemRoot%\System32\net.exe localgroup Administrators ^|^| %SystemRoot%\System32\net.exe localgroup Администраторы`) DO (
	ECHO Found %%~A in the admin group
	IF /I "%%~A"=="%dUsername%" SET "found=1"

	SET "inc=1"
	IF /I "%%~A"=="%USERNAME%" SET "inc="
	IF /I "%%~A"=="Install" SET "inc="
	IF /I "%%~A"=="Администратор" SET "inc="
	IF /I "%%~A"=="Administrator" SET "inc="
	IF /I "%%~A"=="admin-task-scheduler" SET "inc="
	IF DEFINED inc SET /A "adminCount+=1"
    )
    REM if not found, %dUsername% is either not an administrator, or does not exist
    IF NOT DEFINED found (
	ECHO %dUsername% is not an admin, trying to disable unconditionally...
	%SystemRoot%\System32\net.exe user "%dUsername%" /ACTIVE:NO
	EXIT /B
    )
)
(
    IF %adminCount% GTR 1 (
	ECHO Found %adminCount% admins, disabling %dUsername%
	%SystemRoot%\System32\net.exe user "%dUsername%" /ACTIVE:NO
    ) ELSE (
	ECHO %dUsername% is the only admin on %COMPUTERNAME%, shall not be disabled until another admin added
    )
    EXIT /B
)
