@REM coding:OEM
SET tbprofilepassfile=signons.sqlite
SET tbprofiledir=.
FOR /F "usebackq tokens=1* delims==" %%I IN ("%APPDATA%\Thunderbird\profiles.ini") DO IF "%%I"=="Path" (
    SET tbprofiledir=%%J
    GOTO :ExitFor
)
:ExitFor
