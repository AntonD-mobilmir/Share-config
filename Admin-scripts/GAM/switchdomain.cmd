@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    CALL "%~dp0_getGAMpath.cmd"
    IF EXIST "%~dp0auth" SET "authpath=%~dp0auth"
    SET "dfltAuthPath=%LOCALAPPDATA%\_sec\GAM"
)
@(
    IF NOT DEFINED authpath IF EXIST "%dfltAuthPath%" SET "authpath=%dfltAuthPath%"
    IF NOT DEFINED authpath IF EXIST "%GAMpath%\auth" SET "authpath=%GAMpath%\auth"
    IF NOT DEFINED authpath (
	ECHO Стандартные пути к папке токенов oAuth не доступны [см. в %~n0].
	ECHO Укажие путь ^(или оставьте пустым/нажмите Enter, чтобы использовать "%dfltAuthPath%"^):
	SET /P "authpath=> "
    )
    IF NOT DEFINED authpath (
	MKDIR "%dfltAuthPath%"
	SET "authpath=%dfltAuthPath%"
    )
    SET "reqDomain=%~1"
    IF NOT DEFINED reqDomain CALL :SelectDomain
    SET "origPtrPath=%GAMpath%\oauth2-origin.txt"
)
@IF EXIST "%GAMpath%\oauth2.txt" (
    FOR /F "usebackq tokens=* delims=" %%I IN ("%origPtrPath%") DO SET "origname=%%~I"
    IF NOT DEFINED origname (
	ECHO Название посленего использованного домена не прочиталось из "%origPtrPath%". Укажите его вручную, или нажмите Enter, чтобы использовать время файла вместо имени домена.
	SET /P "origname=> "
	IF NOT DEFINED origname FOR %%A IN ("%GAMpath%\oauth2.txt") DO SET "origname=%%~tA"
    )
) ELSE GOTO :SkiporignameProc
@IF NOT "%origname:~0,7%"=="oauth2 " SET "origname=oauth2 %origname::=%"
@IF NOT "%origname:~-4%"==".txt" SET "origname=%origname%.txt"
:SkiporignameProc
(
    IF EXIST "%authpath%\%origname%" (
	ECHO N|COMP "%GAMpath%\oauth2.txt" "%authpath%\%origname%" >NUL
	IF NOT ERRORLEVEL 2 IF ERRORLEVEL 1 MOVE /Y "%authpath%\%origname%" "%authpath%\%origname% %DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2% %TIME::=%.bak"
    )
    MOVE /Y "%GAMpath%\oauth2.txt" "%authpath%\%origname%"
    xln.exe "%authpath%\oauth2 %reqDomain%.txt" "%GAMpath%\oauth2.txt"
    (ECHO %reqDomain%)>"%origPtrPath%"||PAUSE

    IF NOT EXIST "%GAMpath%\client_secrets.json" xln.exe "%authpath%\client_secrets.json" "%GAMpath%\client_secrets.json"

rem     CALL "%~dp0gam.cmd" info user
EXIT /B
)

:SelectDomain
@(
DIR /B "%authpath%\oauth2 *.txt"
SET /P "reqDomain=Имя домена (из списка или другого): "
)
@IF "%reqDomain:~0,7%"=="oauth2 " SET "reqDomain=%reqDomain:~7%"
@(
IF "%reqDomain:~-4%"==".txt" SET "reqDomain=%reqDomain:0,-4%"
EXIT /B
)
