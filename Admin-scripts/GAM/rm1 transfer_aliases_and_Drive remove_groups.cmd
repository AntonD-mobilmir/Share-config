@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    SET "currentemail=%~1"
    SET "subemail=%~2"
    IF NOT DEFINED subemail (
        ECHO �맮�:
        ECHO     %0 ��室��_���짮��⥫� ������⥫�
        ECHO ��室�� ���짮��⥫� �㤥� 㤠��� �� ��� ��㯯, �஬� ��, � ������ �ᥣ� ���� ���⭨�, � ������⥫� ���� ��।��� �� �ᥢ������ � ��� Google ��室���� ���짮��⥫�.
        EXIT /B 10000
    )
    CALL :SplitEmail %1 emailid domain
    CALL :SplitEmail %2 subemailid domainsub
)
(
    IF NOT "%domain%"=="%domainsub%" (
        ECHO ������⥫� ������ ���� � ⮬ �� ������, �� � ��室�� ���짮��⥫�.
        EXIT /B 10000
    )
    IF NOT "%currentemail:~0,4%"=="-rm-" (
        ECHO ���筮 㤠���� �� ��㯯 � ��।����� �ᥢ������ ���� ��᫥ ��२��������� ���짮��⥫� � ��� ��஫� ^(�. https://trello.com/c/2lL0m4fU/^)
        ECHO �᫨ �த������, �ਯ� �믮������ ��� ⥪�饩 ���⭮� ����� ^(%1^), �� ���� �㭪権 [��।�� �ᥢ������] �� �㤥� �믮����� ���������.
        PAUSE
    )
    IF "%emailid:~0,4%"=="-rm-" SET "nonrmemailid=%emailid:~4%"
)
(
    CALL "%~dp0switchdomain.cmd" "%domain%"
    
    CALL "%~dp0gam.cmd" print group-members member "%~1">"%~dp0userinfo Groups %domain% %emailid%.txt"
    CALL :FindAutohotkeyExe "%~dp0CheckGroupsForOneMemberOnly.ahk" "%~dp0userinfo Groups %domain% %emailid%.txt"
    IF ERRORLEVEL 1 (
        ECHO ��। �த��������, ࠧ������ � ��㯯��� � ����� ���⭨��� - ���� 㤠��� ��, ���� ������� ��� ������ ���⭨��.
        EXIT /B
    )
    
    CALL "%~dp0gam.cmd" info user "%~1" noLicenses noGroups >"%~dp0userinfo Aliases %domain% %emailid%.txt"
    CHCP 1251
    FOR /F "usebackq delims=[] tokens=1" %%A IN (`TYPE "%~dp0userinfo Aliases %domain% %emailid%.txt"^|FIND /n "Email Aliases:"`) DO SET /A "AliasesSkipLines=%%~A"
)
IF DEFINED AliasesSkipLines FOR /F "usebackq skip=%AliasesSkipLines% delims=" %%A IN ("%~dp0userinfo Aliases %domain% %emailid%.txt") DO (
    IF "%%~A"=="Non-Editable Aliases:" GOTO :ExitForAliases
    CALL "%~dp0gam.cmd" update alias %%A user "%subemail%"
)
:ExitForAliases
CHCP 866
(
    ECHO �������� �� ��� ��㯯
    CALL "%~dp0gam.cmd" user "%~1" delete groups
    
    rem ECHO ��।�� ᮤ�ন���� ��᪠ Google
    rem CALL "%~dp0gam.cmd" user %1 transfer drive %2
    rem WARNING: [Errno 2] No such file or directory: 'D:\\Users\\LogicDaemon\\AppData\\Local\\Programs\\Google Apps Manager (GAM)\\GAM-4.88\\src\\oauth2service.json'
    rem Please run

    rem gam create project
    rem gam user <user> check serviceaccount

    rem to create and configure a service account.
    
    EXIT /B
)

:SplitEmail <email> <emailid-var> <domain-var>
(
    FOR /F "delims=@ tokens=1*" %%A IN ("%~1") DO (
        SET "%~2=%%~A"
        SET "%~3=%%~B"
    )
EXIT /B
)

:FindAutohotkeyExe
(
    FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :CheckAutohotkeyExe %%I
    IF NOT DEFINED AutohotkeyExe GOTO :RunFindAutohotkeyExeScript
    IF "%~1"=="" EXIT /B
)
(
    %AutohotkeyExe% %*
    EXIT /B
)
:CheckAutohotkeyExe <path>
(
    IF NOT EXIST %1 EXIT /B 1
    SET AutohotkeyExe=%1
    EXIT /B
)
:RunFindAutohotkeyExeScript
    IF NOT DEFINED configDir CALL :findConfigDir
(
    CALL "%configDir%_Scripts\FindAutoHotkeyExe.cmd" %*
EXIT /B
)
:findConfigDir
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
(
    CALL :GetDir configDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
