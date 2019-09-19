@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF NOT DEFINED srcpath ( IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0" )

    IF NOT DEFINED distFName SET "distFName=Thunderbird Setup *.exe"
    IF NOT DEFINED distSubdir (
        SET "distSubdir=32-bit\"
        IF NOT "%inst32biton64sys%"=="1" (
            IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "distSubdir=64-bit\"
            IF DEFINED PROCESSOR_ARCHITEW6432 SET "distSubdir=64-bit\"
        )
    )
    IF DEFINED ProgramW6432 (
        IF NOT "%inst32biton64sys%"=="1" (
            SET "lProgramFiles=%ProgramFiles(x86)%"
        ) ELSE (
            SET "lProgramFiles=%ProgramW6432%"
        )
    ) ELSE (
        IF NOT "%inst32biton64sys%"=="1" (
            SET "lProgramFiles=%ProgramFiles(x86)%"
        ) ELSE (
            SET "lProgramFiles=%ProgramFiles%"
        )
    )
)
SET "distDir=%srcpath%%distSubdir%"
(
    FOR /F "usebackq delims=" %%I IN (`DIR /B /O-D "%distDir%%distFName%"`) DO SET "distFName=%%~I" & GOTO :Found
    ECHO Distributive not found!
    EXIT /B 1
)
:Found
(
    SET "lProgramFiles=%lProgramFiles%"
    SET "distFullPath=%distDir%%distFName%"
    ECHO Distributive: %distDir%%distFName%
    EXIT /B 0
)
