@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

ECHO %DATE% %TIME% %0 %*
DIR %1
PUSHD %1 && START "" /B /LOW "c:\Program Files\7-Zip\7z.exe" a -mx=9 "r:\WindowsImageBackup-archives\%~nx1.7z" && ( POPD & RD /S /Q %1 )
DIR "%~dp1"
) >>"%~dpn0-%~nx1.log" 2>&1
