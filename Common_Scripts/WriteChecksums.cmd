@REM coding:OEM
@ECHO OFF
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
REM
REM This work by LogicDaemon is licensed under a Creative Commons Attribution 3.0 Unported License.
REM http://creativecommons.org/licenses/by/3.0/
SETLOCAL ENABLEEXTENSIONS

IF "%~1"=="" GOTO :help

:nextarg
SET checksumsRoot=%~dp1
FOR /R %%I IN (%1) DO CALL :WriteSums "%%~I"
SHIFT
IF NOT "%~1"=="" GOTO :nextarg

EXIT /B

:WriteSums <filepath>
(
    IF "%~nx1"=="checksums.md5" EXIT /B
    IF "%~nx1"=="checksums.sha1" EXIT /B
    IF "%~nx1"=="checksums.sha256" EXIT /B

    ECHO Writing checksums for %~nx1
    SET TargetFileName=%~nx1
    CALL :RunInParralel md5 c:\SysUtils\gnupg\md5sum.exe %*
    CALL :RunInParralel sha1 c:\SysUtils\gnupg\sha1sum.exe %*
    CALL :RunInParralel sha256 c:\SysUtils\gnupg\sha256sum.exe %*
)
:wait
(
    PING 127.0.0.1 -n 2 >NUL
    FOR /F "usebackq delims== tokens=1*" %%J IN (`SET runningflag_`) DO IF EXIST "%%~K" GOTO :wait
    ENDLOCAL
)
EXIT /B

:RunInParralel <hash_name> <hash_executable> <params>
(
    SETLOCAL
    SET "hash_name=%~1"
    SET "hash_executable=%~2"
    SET "runningflag=%TEMP%\.%~1.%RANDOM%.running"
    SET params=
)
:nextparam
(
    CALL :appendparams %3
    SHIFT
)
(
    IF NOT "%~3"=="" GOTO :nextparam

    START "Calculating %hash_name% for %TargetFileName%" /MIN /LOW %comspec% /C ^( %hash_executable% %params% ^>^> "%checksumsRoot%checksums.%hash_name%" 2^>"%runningflag%" ^) ^&^& DEL "%runningflag%"
    ENDLOCAL
    ECHO "runningflag_%hash_name%=%runningflag%"
    SET "runningflag_%hash_name%=%runningflag%"
)
EXIT /B

:help
    ECHO help to be written
EXIT /B

:appendparams
    SET params=%params% %*
EXIT /B
