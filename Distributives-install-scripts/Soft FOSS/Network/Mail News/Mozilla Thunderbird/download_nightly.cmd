@REM coding:OEM
REM                                     Automated software update scripts
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru

VERIFY OTHER 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 echo Unable to enable extensions
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

START "" /B /WAIT /D"%srcpath%temp\" wget -r -np -N -e robots=off -A.exe,.asc http://ftp.mozilla.org/pub/mozilla.org/thunderbird/nightly/latest-comm-1.9.2/
START "" /B /WAIT /D"%srcpath%temp\" wget -r -np -N -e robots=off -A.exe,.asc http://ftp.mozilla.org/pub/mozilla.org/thunderbird/nightly/latest-comm-central/
