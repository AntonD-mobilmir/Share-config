@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    %SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )

    SET "t=%TEMP%\%~n0.%DATE:/=_%.tmp"
)
(
    MKDIR "%t%"
    SET s="%t%\diskpart-scenario.txt"
)
@(
    (
        ECHO LIST VOLUME
    )>%s%
    DISKPART /S %s%>"%t%\vol.txt"
    IF ERRORLEVEL 1 PAUSE
    rem   Volume 4         SwapSpace    NTFS   Partition   2055 MB  Healthy            
    rem     C:\Windows\SwapSpace\ 
    rem   Том    ###  Имя  Метка        ФС     Тип         Размер   Состояние  Сведения
    rem   ----------  ---  -----------  -----  ----------  -------  ---------  --------
    rem      Том 0         Восстановит  NTFS   Раздел       499 Mб  Исправен
    rem      Том 1     C   System       NTFS   Раздел        63 Gб  Исправен   Загрузоч
    rem      Том 2     D   Data         NTFS   Раздел       174 Gб  Исправен
    rem      Том 3                      FAT32  Раздел        99 Mб  Исправен   Системны
    
    REM Вариант 0
    rem      Том 4                      NTFS   Раздел      2048 Mб  Исправен
    REM      1   2                      3      4           5    6   7           8
    REM          A                      B      C           D    E   F           G
    
    REM Вариант 1
    rem      Том 3         SwapSpace    NTFS   Раздел      2048 Mб  Исправен
    REM      1   2         3            4      5              6 7   8           9
    REM          A         B            C      D              E F   G

    REM Вариант 2
    rem      Том 4     S                NTFS   Раздел      2048 Mб  Исправен
    REM      1   2     3                4      5              6 7   8           9
    REM          A     B                C      D              E F   G
    
    REM Вариант 3
    rem      Том 3     S   SwapSpace    NTFS   Раздел      2048 Mб  Исправен
    REM      1   2     3   4            5      6              7 8   9           10
    REM          A     B   C            D      E              F G

    REM                     A B C D E F
    FOR /F "usebackq tokens=2,3,4,5,6,7,8 delims= " %%A IN ("%t%\vol.txt") DO (
        IF "%%~B"=="Раздел" ( REM без метки, без буквы и без ФС
            IF "%%~C"=="2048" CALL :IfInList "%%~D" "MB" "Mб" && (SET "volnum=%%~A" & GOTO :foundvol)
        ) ELSE IF "%%~B"=="RAW" ( REM без метки, без буквы и без ФС, вариант Win10
            IF "%%~D"=="2048" CALL :IfInList "%%~E" "MB" "Mб" && (SET "volnum=%%~A" & GOTO :foundvol)
        ) ELSE IF "%%~B"=="NTFS" ( REM без метки, без буквы
            IF "%%~D"=="2048" CALL :IfInList "%%~E" "MB" "Mб" && (SET "volnum=%%~A" & GOTO :foundvol)
        ) ELSE ( REM с меткой или буквой
            IF "%%~B"=="SwapSpace" SET "volnum=%%~A" & GOTO :foundvol
            IF "%%~C"=="SwapSpace" SET "volnum=%%~A" & GOTO :foundvol
            
            REM без метки, но с буквой
            IF "%%~E"=="2048" CALL :IfInList "%%~F" "MB" "Mб" && (SET "volnum=%%~A" & GOTO :foundvol)
            IF "%%~F"=="2048" CALL :IfInList "%%~E" "MB" "Mб" && (SET "volnum=%%~A" & GOTO :foundvol)
            REM с меткой и буквой, без ФС быть не может ибо откуда иначе метка
            IF "%%~D"=="NTFS" IF "%%~F"=="2048" CALL :IfInList "%%~G" "MB" "Mб" && (SET "volnum=%%~A" & GOTO :foundvol)
        )
    )
    TYPE "%t%\vol.txt"
    ECHO Том с меткой SwapSpace либо размером 2048 Мб не найден.
    ECHO Нажмите любую клавишу для выхода.
    PAUSE>NUL
    EXIT /B
)
:foundvol
@(
    (
        ECHO SELECT VOLUME=%volnum%
        ECHO LIST DISK
        ECHO LIST PART
        ECHO LIST VOLUME
        ECHO DETAIL VOLUME
        ECHO DETAIL PARTITION
    )>%s%
    DISKPART /S %s%
    ECHO Если продолжить, том %volnum% будет отформатирован и ему будет назначена точка монтирования %SystemRoot%\SwapSpace
    PAUSE
    (
        ECHO SELECT VOLUME=%volnum%
        ECHO REMOVE ALL DISMOUNT
    )>%s%
    DISKPART /S %s%
    (
        ECHO SELECT VOLUME=%volnum%
        ECHO FORMAT FS=NTFS LABEL=SwapSpace UNIT=65536 QUICK
        ECHO ASSIGN MOUNT=%SystemRoot%\SwapSpace
    )>%s%
    RD "%SystemRoot%\SwapSpace" 2>NUL
    MD "%SystemRoot%\SwapSpace" || EXIT /B
    DISKPART /S %s%
    RD /S /Q "%t%" 2>NUL
    EXIT /B
)

:IfInList
(
    IF /I "%~1"=="%~2" EXIT /B 0
    IF "%~2"=="" EXIT /B 1
    SHIFT /2
GOTO :IfInList
)
