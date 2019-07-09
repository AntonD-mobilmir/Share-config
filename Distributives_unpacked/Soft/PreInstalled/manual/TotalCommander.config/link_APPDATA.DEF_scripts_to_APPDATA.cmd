@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
    
    SET "dest=%APPDATA%\GHISLER\"
    SET "src=%~dp0APPDATA.DEF\GHISLER\"
)
@(
    IF NOT EXIST "%dest%" (
        ECHO [^!] Папки "%dest%" не существует.
        PING -n 3 127.0.0.1 >NUL
        EXIT /B
    )
    FOR %%A IN ("%src%*.ahk" "%src%pci.db" "%src%usercmd.ini") DO @(
        SET "compSrcFile=%%~A"
        SET "compDestFile=%dest%!compSrcFile:%src%=!"
        IF EXIST "!compDestFile!" (
            FC "%%~A" "!compDestFile!" >NUL
            IF ERRORLEVEL 2 (
                ECHO [^!] Ошибка при сравнении "%%~A"
                PING -n 3 127.0.0.1 >NUL
                SET "skip=2"
            ) ELSE IF ERRORLEVEL 1 (
                ECHO [*] Файл "!compDestFile!" отличается от "%%~A"
                SET "skip=1"
            ) ELSE (
                ECHO [-] "!compDestFile!" [= "%%~A"]
                DEL "!compDestFile!"
                SET "skip="
            )
        ) ELSE (
            SET "skip="
        )
        IF NOT DEFINED skip MKLINK "!compDestFile!" "%%~A"
    )
EXIT /B
)
