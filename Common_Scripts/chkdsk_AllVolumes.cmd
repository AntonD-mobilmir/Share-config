@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

FOR /F "usebackq delims=" %%I IN (`mountvol`) DO CALL :CheckVolumeName "%%~I"
EXIT /B

:CheckVolumeName
    SET volname=%~1
    SET prefix=%volname:~0,8%
    IF "%prefix%"=="    \\?\" ECHO Y | CHKDSK /X %volname:~4,-1%
EXIT /B
