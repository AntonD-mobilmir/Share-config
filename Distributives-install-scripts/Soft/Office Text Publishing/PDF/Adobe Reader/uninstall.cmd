@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS

REM Adobe Reader XI
CALL :runMsiExec /X{AC76BA86-7AD7-1049-7B44-AB0000000001} /qn
REM Acrobat Reader DC
CALL :runMsiExec /X{AC76BA86-7AD7-1049-7B44-AC0F074E4100} /qn

FOR /R %%A IN ("%ProgramData%\Adobe\ARM\*.msi") DO CALL :runMsiExec /X "%%~A" /qn
RD /S /Q "%ProgramData%\Adobe\ARM"

EXIT /B
)
:runMsiExec
(
    %SystemRoot%\System32\msiexec.exe %*
    IF ERRORLEVEL 1618 IF NOT ERRORLEVEL 1619 ( PING 127.0.0.1 -n 30 >NUL & GOTO :runMsiExec ) & rem another install in progress, wait and retry
EXIT /B
)
