@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
)
(
    :gpgagain
    SET "err="
    IF NOT EXIST %1 IF EXIST "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Administrators\%~1" CALL :GpgWith1stArgPath %*
    IF NOT DEFINED gpgRan gpg.exe -o- -d %*|clip || SET "err=1"
    
    IF DEFINED err IF DEFINED gpgtry2 ( PAUSE & EXIT /B ) ELSE TASKKILL /F /IM gpg-agent.exe & GOTO :gpgagain
    
    FOR %%I IN ("%ProgramFiles%" "%ProgramFiles(x86)%") DO IF EXIST "%%~I\Notepad2\Notepad2.exe" (
        START "" "%%~I\Notepad2\Notepad2.exe" /c
        EXIT /B
    )

    ECHO Notepad2 not found, decrypted text is in clipboard
    PAUSE>NUL
EXIT /B
)

:GpgWith1stArgPath
(
    SETLOCAL ENABLEDELAYEDEXPANSION
    SET skip=1

    FOR %%I IN (%*) DO IF !skip! LEQ 0 (
        SET "params=!params! %%I"
    ) ELSE SET /A skip-=1
)
(
    ENDLOCAL
    SET "params=%params%"
)
(
    SET "gpgRan=1"
    gpg.exe -o- -d "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Administrators\%~1" %params% |clip || SET "err=1"
EXIT /B
)
