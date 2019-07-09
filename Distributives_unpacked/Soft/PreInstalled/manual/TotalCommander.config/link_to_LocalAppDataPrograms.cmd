@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
    
    SET "dest=%LocalAppData%\Programs\Total Commander\"
    SET "src=%~dp0"
)
@(
    IF /I "%dest%"=="%src%" (
        ECHO FFS dest=src :-[
        PING -n 3 127.0.0.1 >NUL
        EXIT /B
    )
    IF NOT EXIST "%dest%" (
        ECHO [*] Папки "%dest%" не существует.
        PING -n 3 127.0.0.1 >NUL
        EXIT /B
    )
    FOR /F "usebackq delims=" %%A IN (`DIR /S /A-L-D /B "%~dp0*.*"`) DO @(
        SET "pathSrcFile=%%~A"
        SET "pathDestFile=%dest%!pathSrcFile:%src%=!"
        IF EXIST "!pathDestFile!" (
            MOVE /Y "%%~A" "%%~A.bak" || PAUSE
            MOVE /Y "!pathDestFile!" "!pathDestFile!.bak" || PAUSE
            FC "%%~A.bak" "!pathDestFile!.bak" >NUL
            IF ERRORLEVEL 2 (
                SET "skip=2"
                ECHO [*] Ошибка при сравнении "%%~A"
            ) ELSE IF ERRORLEVEL 1 (
                SET "skip=1"
                ECHO [*] "%%~A" отличается
            ) ELSE ( REM files are the same
                SET "skip="
                ECHO [-] "%%~A.bak"
                DEL "%%~A.bak"
            )
        ) ELSE ( REM !pathDestFile! does not exist
            MOVE "%%~A" "!pathDestFile!"
            SET "skip="
        )
        MOVE "!pathDestFile!.bak" "!pathDestFile!"
        IF DEFINED skip (
            MOVE "%%~A.bak" "%%~A"
        ) ELSE (
            REM symlinks require admin rights
            MKLINK "%%~A" "!pathDestFile!" || MKLINK /H "%%~A" "!pathDestFile!"
        )
    )
EXIT /B
)
