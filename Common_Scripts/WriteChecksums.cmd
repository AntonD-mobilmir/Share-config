@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

IF "%~1"=="" GOTO :help
)
:nextarg
(
    SET "checksumsRoot=%~dp1"
    FOR /R %%I IN ("%~1") DO CALL :WriteSums "%%~I"
    IF NOT "%~2"=="" (
	SHIFT
	GOTO :nextarg
    )
EXIT /B
)

:WriteSums <filepath>
(
    IF "%~nx1"=="checksums.md5" EXIT /B
    IF "%~nx1"=="checksums.sha1" EXIT /B
    IF "%~nx1"=="checksums.sha256" EXIT /B

    ECHO Writing checksums for %~nx1
    SET "TargetFileName=%~nx1"
    CALL :RunInParralel md5 %SystemDrive%\SysUtils\md5sum.exe %*
    CALL :RunInParralel sha1 %SystemDrive%\SysUtils\sha1sum.exe %*
    CALL :RunInParralel sha256 %SystemDrive%\SysUtils\sha256sum.exe %*
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
(
    ECHO help to be written
EXIT /B
)
:appendparams
(
    SET "params=%params% %*"
EXIT /B
)
