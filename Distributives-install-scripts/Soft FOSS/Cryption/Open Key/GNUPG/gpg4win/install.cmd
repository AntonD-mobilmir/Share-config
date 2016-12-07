@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET dist=gpg4win-light-*.exe

FOR %%I IN ("%dist%") DO (
    SET "dist=%%~I"
    GOTO :found
)
ECHO distributive not found!
EXIT /B 1

:found
rem REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\GNU\GnuPG" /v "Install Directory" /t REG_SZ /d "c:\SysUtils\gnupg" /f
"%dist%" /S /D"C:\SysUtils\gnupg"
