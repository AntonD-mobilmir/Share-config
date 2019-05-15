@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

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
    rem   ���    ###  ���  ��⪠        ��     ���         ������   ����ﭨ�  ��������
    rem   ----------  ---  -----------  -----  ----------  -------  ---------  --------
    rem      ��� 0         ����⠭����  NTFS   ������       499 M�  ��ࠢ��
    rem      ��� 1     C   System       NTFS   ������        63 G�  ��ࠢ��   ����㧮�
    rem      ��� 2     D   Data         NTFS   ������       174 G�  ��ࠢ��
    rem      ��� 3                      FAT32  ������        99 M�  ��ࠢ��   ���⥬��
    
    REM ��ਠ�� 0
    rem      ��� 4                      NTFS   ������      2048 M�  ��ࠢ��
    REM      1   2                      3      4           5    6   7           8
    REM          A                      B      C           D    E   F           G
    
    REM ��ਠ�� 1
    rem      ��� 3         SwapSpace    NTFS   ������      2048 M�  ��ࠢ��
    REM      1   2         3            4      5              6 7   8           9
    REM          A         B            C      D              E F   G

    REM ��ਠ�� 2
    rem      ��� 4     S                NTFS   ������      2048 M�  ��ࠢ��
    REM      1   2     3                4      5              6 7   8           9
    REM          A     B                C      D              E F   G
    
    REM ��ਠ�� 3
    rem      ��� 3     S   SwapSpace    NTFS   ������      2048 M�  ��ࠢ��
    REM      1   2     3   4            5      6              7 8   9           10
    REM          A     B   C            D      E              F G

    REM                     A B C D E F
    FOR /F "usebackq tokens=2,3,4,5,6,7,8 delims= " %%A IN ("%t%\vol.txt") DO (
        IF "%%~B"=="������" ( REM ��� ��⪨, ��� �㪢� � ��� ��
            IF "%%~C"=="2048" CALL :IfInList "%%~D" "MB" "M�" && (SET "volnum=%%~A" & GOTO :foundvol)
        ) ELSE IF "%%~B"=="RAW" ( REM ��� ��⪨, ��� �㪢�
            IF "%%~D"=="2048" CALL :IfInList "%%~E" "MB" "M�" && (SET "volnum=%%~A" & GOTO :foundvol)
        ) ELSE IF "%%~B"=="NTFS" ( REM ��� ��⪨, ��� �㪢�
            IF "%%~D"=="2048" CALL :IfInList "%%~E" "MB" "M�" && (SET "volnum=%%~A" & GOTO :foundvol)
        ) ELSE (
            IF "%%~B"=="SwapSpace" SET "volnum=%%~A" & GOTO :foundvol
            IF "%%~C"=="SwapSpace" SET "volnum=%%~A" & GOTO :foundvol
            
            IF "%%~�"=="NTFS" IF "%%~E"=="2048" CALL :IfInList "%%~F" "MB" "M�" && (SET "volnum=%%~A" & GOTO :foundvol)
            IF "%%~D"=="NTFS" IF "%%~F"=="2048" CALL :IfInList "%%~G" "MB" "M�" && (SET "volnum=%%~A" & GOTO :foundvol)
        )
    )
    TYPE "%t%\vol.txt"
    ECHO ��� � ��⪮� SwapSpace ���� ࠧ��஬ 2048 �� �� ������.
    ECHO ������ ���� ������� ��� ��室�.
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
    ECHO �᫨ �த������, ⮬ %volnum% �㤥� ���ଠ�஢�� � ��� �㤥� �����祭� �窠 ����஢���� %SystemRoot%\SwapSpace
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
