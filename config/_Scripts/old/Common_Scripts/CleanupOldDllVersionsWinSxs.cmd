@REM coding:OEM
@ECHO OFF

ECHO Before cleanup:
du %SystemRoot%\WinSxS
dism /online /cleanup-image /spsuperseded
ECHO After cleanup:
du %SystemRoot%\WinSxS
