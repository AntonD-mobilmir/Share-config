@(REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
CALL "%~dp0_getGAMpath.cmd"
SET "timeFNameSuffix=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2% %TIME::=%"
)
(
IF EXIST "%~dp0auth" (
    SET "authpath=%~dp0auth"
) ELSE SET "authpath=%GAMpath%\auth"
SET "origPtrPath=%GAMpath%\oauth2-origin.txt"
)
(
MKDIR "%authpath%"
FOR /F "usebackq delims=" %%I IN ("%origPtrPath%") DO SET "origname=%authpath%\%%~I"
)
(
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
