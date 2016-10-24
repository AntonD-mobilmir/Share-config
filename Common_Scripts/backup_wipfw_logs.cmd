@REM coding:OEM
@ECHO OFF

SET archivename=%SystemRoot%\security\logs\wipfw-logs.rar
SET source=%SystemRoot%\security\logs\wipfw*.log

IF EXIST "%archivename%" (
	IF EXIST "%archivename%.bak" del "%archivename%.bak"
	REN "%archivename%" *.*.bak
)

rar m "%archivename%" "%source%"
