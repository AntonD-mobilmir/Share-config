@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

SET "today=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%"
IF NOT "%~1"=="" ( SET "basedir=%~1\" ) ELSE IF "%basedir%"=="" SET "basedir=%CD%\"
IF NOT "%~2"=="" SET "suffix= %~2"
)
(
IF "%basedir%"=="%SystemRoot%\" (
    ECHO Base directory is SystemRoot, aborting
    EXIT /B 2
)
SET "mkdir_today=%basedir%%today%%suffix%"
)
MKDIR "%mkdir_today%"
