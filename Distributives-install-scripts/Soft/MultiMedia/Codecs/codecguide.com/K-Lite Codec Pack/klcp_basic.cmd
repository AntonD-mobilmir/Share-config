@REM coding:OEM
SETLOCAL

REM -MakeUnattended
FOR /F "usebackq delims=" %%I IN (`DIR /B /O-N "%~dp0K-Lite_Codec_Pack_*_Basic.exe"`) DO (
    SET "dist=%~dp0%%~I"
    GOTO :distFound
)
ECHO Distributive not found!
EXIT /B 1
:distFound

FOR /F "usebackq delims=" %%I IN (`DIR /B /O-N "%~dp0klcp_update_*.exe"`) DO (
    SET "update=%~dp0%%~I"
    GOTO :updateFound
)
ECHO Update not found!
:updateFound

"%dist%" /verysilent /norestart /LoadInf="%~dpn0.ini"
IF DEFINED update "%update%" /verysilent /norestart
rem /LoadInf="%~dpn0.ini" not needed for update
ENDLOCAL
