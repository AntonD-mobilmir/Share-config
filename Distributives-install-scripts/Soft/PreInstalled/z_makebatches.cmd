@REM coding:OEM
@ECHO OFF
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

FOR %%I IN ("%srcpath%auto\*.*" "%srcpath%manual\*.*") DO CALL :copytemplate "%%~I"

PAUSE

EXIT /B

:copytemplate
    SET templatecmd=%srcpath%doc\template%~x1.cmd
    SET batch=%~dpn1.cmd
    IF NOT EXIST "%batch%" IF EXIST "%templatecmd%" (
	ECHO Copying batch for %1
	COPY /B "%templatecmd%" "%batch%" >nul
    )
EXIT /B
