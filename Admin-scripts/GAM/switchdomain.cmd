@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    CALL "%~dp0_getGAMpath.cmd"
    SET "timeFNameSuffix=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2% %TIME::=%"
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
    SET "origPtrPath=%GAMpath%\oauth2-origin.txt"
)
@FOR /F "usebackq delims=" %%I IN ("%origPtrPath%") DO SET "origname=%authpath%\%%~I"
@(
    IF EXIST "%origname%" (
	ECHO N|COMP "%GAMpath%\oauth2.txt" "%origname%" >NUL
	IF NOT ERRORLEVEL 2 IF ERRORLEVEL 1 MOVE /Y "%origname%" "%origname% %timeFNameSuffix%.bak"
    )
    MOVE /Y "%GAMpath%\oauth2.txt" "%origname%"
    xln.exe "%authpath%\oauth2 %1.txt" "%GAMpath%\oauth2.txt"
    ECHO "oauth2 %1.txt">"%origPtrPath%"||PAUSE

    IF NOT EXIST "%GAMpath%\client_secrets.json" xln.exe "%authpath%\client_secrets.json" "%GAMpath%\client_secrets.json"

    CALL "%~dp0gam.cmd" info user
)
