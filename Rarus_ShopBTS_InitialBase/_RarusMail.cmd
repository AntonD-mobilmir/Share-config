@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

rem workaround for starting sed.exe in same batch as first run of software_install.cmd
SET "PATH=%PATH%;%SystemDrive%\SysUtils\libs"

IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
SET "RarusPostDir=d:\1S\Rarus\ShopBTS\ExtForms\post\"
SET "overwritecfg=1"

CALL "%~dp0MailLoader\install.cmd"
)
CALL :GetDir ConfigDir %DefaultsSource%

IF EXIST "%RarusPostDir%sendemail.cfg" (
    ECHO %RarusPostDir%sendemail.cfg 㦥 �������, ��१������?
    ECHO 1=��, � �������� ����� ����� � prefs.js Thunderbird prefs.js
    ECHO 2=���, �� �������� ����� ����� � prefs.js
    ECHO ��⠫쭮�=���, ��ࢠ��
    SET /P "overwritecfg=[1|2|*]"
    IF NOT DEFINED overwritecfg EXIT /B
)
CALL :GetRarusExchParams
GOTO :overwritecfg%overwritecfg%
EXIT /B
:overwritecfg1
(
    PUSHD "%RarusPostDir%"||(ECHO �� 㤠���� ��३� � ����� ���⮢��� �ਯ� � �����. �믮������ �㤥� ��ࢠ��. & PAUSE & EXIT /B)
	(ECHO %rarusexchaddr%)>sendemail.cfg
	ECHO ������ ��஫� �� ����� ��ப�
	PING 127.0.0.1 -n 3 >NUL
	%SystemRoot%\System32\notepad.exe %RarusPostDir%sendemail.cfg
    POPD
)
:overwritecfg2
(
rem IF NOT DEFINED sedexe CALL "%ConfigDir%_Scripts\find_exe.cmd" sedexe sed.exe "%SystemDrive%\SysUtils\UnxUtils\sed.exe" || (ECHO �� ������ sed.exe ��� ��ࠢ����� ��䨫� Thunderbird. & PAUSE & EXIT /B)
IF NOT DEFINED sedexe CALL "%ConfigDir%_Scripts\findsedexe.cmd" || (ECHO �� ������ sed.exe ��� ��ࠢ����� ��䨫� Thunderbird. & PAUSE & EXIT /B)
IF NOT DEFINED mtprofiledir CALL :CheckExistenceSetVar mtprofiledir d:\Mail\Thunderbird\profile
)
(
    SET "ErrorsHappened=0"
    PUSHD "%mtprofiledir%"||(PAUSE & EXIT /B)
	%sedexe% -e "s/!rarusexchaddr!/%rarusexchaddr%/g" -e "s/!rarusexchlogin!/%rarusexchaddr%/g" prefs_RarusExch.js >>prefs.js || CALL :CheckError
	%sedexe% -ir -f prefs_AddRarusExchAcc.sed prefs.js || CALL :CheckError
    POPD
)
(
    IF "%ErrorsHappened%"=="0" (
	DEL "%mtprofiledir%\prefs_RarusExch.js"
	DEL "%mtprofiledir%\prefs_AddRarusExchAcc.sed"
    )
    EXIT /B
)
:GetRarusExchParams
(
    IF DEFINED rarusexchaddr GOTO :SkipAcquiringUserName

    CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
)
    IF DEFINED mailuserid (
	SET "rarusexchuser=%mailuserid%"
    ) ELSE (
	SET /P "rarusexchuser=���� �騪� ����� ����� (��� @k.mobilmir.ru): "
    )
    SET "rarusexchaddr=%rarusexchuser%@k.mobilmir.ru"
:SkipAcquiringUserName
EXIT /B

:CheckExistenceSetVar
    IF EXIST "%~2" (
	SET %~1=%2
    ) ELSE (
	SET /P "%1=%2 not found. Enter correct path for %1: "
    )
EXIT /B

:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)

:CheckError
(
    SET /A ErrorsHappened+=1
    SET "LastError=%ERRORLEVEL%"
    IF DEFINED ErrorList (
	SET "ErrorList=%ErrorList%;%ERRORLEVEL%"
    ) ELSE SET "ErrorList=%ERRORLEVEL%"
    EXIT /B
)
