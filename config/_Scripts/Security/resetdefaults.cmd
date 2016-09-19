@REM coding:OEM

rem http://helpdeskgeek.com/how-to/reset-local-security-policy/
rem secedit /configure /cfg %windir%\inf\defltbase.inf /db defltbase.sdb

SET seceddb=%SystemRoot%\security\Database\secedit.sdb
IF NOT DEFINED ErrorCmd SET ErrorCmd=SET ErrorPresence=1

IF NOT EXIST "%seceddb%.org" COPY /B "%seceddb%" "%seceddb%.org"
IF "%secVer%"=="5" COPY /Y /B "%~dp0XP Service Pack 3.sdb" "%seceddb%.new"||(%ErrorCmd% & EXIT /B 1)
"%SystemRoot%\System32\secedit.exe" /configure /db "%seceddb%.new" /cfg "%SystemRoot%\inf\defltbase.inf"
MOVE /Y "%seceddb%.new" "%seceddb%"||%ErrorCmd%
