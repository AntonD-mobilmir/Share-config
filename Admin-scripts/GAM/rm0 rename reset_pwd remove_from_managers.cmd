@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    IF "%~1"=="" (
        ECHO ����뢠�� ��஫� ���짮��⥫�, ��२�����뢠�� ��� � 㤠��� �� ��㯯� managers@mobilmir.ru
        ECHO �ᯮ�짮�����:
        ECHO     %0 ^<email^> [����_��஫�]
        EXIT /B 10000
    )
    FOR /F "delims=@ tokens=1*" %%A IN ("%~1") DO (
        SET "emailid=%%~A"
        SET "domain=%%~B"
    )
    IF "%~2"=="" (
        CALL :GeneratePassword pwd
    ) ELSE (
        SET "pwd=%~2"
        SET "recordpwd=1"
    )
)
(
    IF DEFINED recordpwd (
        MKDIR "%TEMP%\%~n0.e"
        CIPHER /E "%TEMP%\%~n0.e"
        (
            ECHO %pwd%
        )>>"%TEMP%\%~n0.e\password %domain% %emailid%.txt"
    )
    
    CALL "%~dp0switchdomain.cmd" "%domain%"
    CALL "%~dp0gam.cmd" update user %1 firstname "-" lastname "(���짮��⥫� 㤠���)" gal off username "-rm-%emailid%" password "%pwd%" nohash changepassword off
    
    CALL "%~dp0switchdomain.cmd" "mobilmir.ru"
    CALL "%~dp0gam.cmd" update group "managers@mobilmir.ru" remove user "%~1"
    CALL "%~dp0gam.cmd" update group "managers-mobilmir@mobilmir.ru" remove user "%~1"
    rem CALL "%~dp0gam.cmd" update group managers@mobilmir.ru remove user "-rm-%~1"
        
    (
        ECHO %DATE% %TIME%
        CALL "%~dp0gam.cmd" info user "-rm-%~1"
    ) >>"%~dp0userinfo %domain% %emailid%.txt"
    CHCP 1251
)
(
    TYPE "%~dp0userinfo %domain% %emailid%.txt"
    CHCP 866
EXIT /B
)
:GeneratePassword
(
    SET "%~1=%RANDOM%-%RANDOM%-%RANDOM%"
EXIT /B
)
