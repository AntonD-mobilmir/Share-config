@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

CALL "%~dp0..\CheckWinVer.cmd" 6 || EXIT /B & REM Not working on XP
CALL "%~dp0..\CheckWinVer.cmd" 6.2 && (
    %SystemRoot%\System32\TAKEOWN.exe %* /D Y /R /SKIPSL
    EXIT /B
)
CALL :ParseTAKEOWNArgs %*
)
(
rem TODO: Recurse folders avoiding reparse points and symlinks
%SystemRoot%\System32\TAKEOWN.exe %*
rem так нельзя, см. http://superuser.com/a/1132107/131936 -- FOR /F "usebackq delims=" %%A IN (`DIR "%tgt%" /S /B /AD-L`) DO %SystemRoot%\System32\TAKEOWN.exe /F "%%~A\*.*" %TAKEOWNArgs%
CALL :procDir "%tgt%"
EXIT /B
)

:procDir <path>
(
    %SystemRoot%\System32\TAKEOWN.exe /F "%~1\*.*" %TAKEOWNArgs%
    FOR /F "usebackq delims=" %%A IN (`DIR %1 /B /AD-L`) DO CALL :procDir "%~1\%%~A"
EXIT /B
)
:ParseTAKEOWNArgs <takeown-args>
IF "%~1"=="/F" (
    SET "tgt=%~2"
    SHIFT
    SHIFT
    GOTO :ParseTAKEOWNArgs
)
SET TAKEOWNArgs=%TAKEOWNArgs% %1
IF NOT "%~1"=="" (
    SHIFT
    GOTO :ParseTAKEOWNArgs
)
