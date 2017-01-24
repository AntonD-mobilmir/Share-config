@(REM coding:CP866
rem TODO: ��ࠡ���� �ਯ� ��⠭����, �⮡� (��樮���쭮) �� �� ��⠭����������, � ����� �⮣� �����뢠���� 䫠�� ��⠭����.

REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
rem @ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
IF NOT DEFINED AutohotkeyExe CALL "%~dp0FindAutoHotkeyExe.cmd"
)
(
    REM weird PATH workaround
    SET "PATH=%PATH%;%ProgramData%\mobilmir.ru\Common_Scripts;%SystemDrive%\SysUtils;%SystemDrive%\SysUtils\libs;%utilsdir%"

    CALL :GetNameNoExt DefaultsName "%DefaultsSource%"

    IF "%~1"=="" GOTO :nomoreargs
    SET "arg=%~1"
)
:nextarg
(
    IF "%arg:~,1%"==":" SET "gotolabel=%arg%"
    SET "%arg%=1"

    SET "arg=%~2"
    SHIFT
    IF NOT "%~2"=="" GOTO GOTO :nextarg
)
:nomoreargs
(
    rem Checking this after processing switches to allow passing RunInteractiveInstalls as an argument
    IF NOT DEFINED ErrorCmd (
	SET "ErrorCmd=ECHO Error!"
	IF "%RunInteractiveInstalls%"=="1" SET "ErrorCmd=ECHO "
    )
)

IF NOT DEFINED InstallQueue CALL "%~dp0Lib\.utils.cmd" GetInstallQueue InstallQueue
START %SystemRoot%\explorer.exe /open,"%InstallQueue%"
MKDIR "%InstallQueue%" 2>NUL
XCOPY "%~dp0InstallQueue.default" "%InstallQueue%" /E /I /H /Y
XCOPY "%~dp0InstallQueue.%DefaultsName%" "%InstallQueue%" /E /I /H /Y

rem TODO: ��ࠡ���� �ਯ� ��⠭����, �⮡� ᫥���饥 �� (��樮���쭮) �� ��⠭����������, � ����� �⮣� �����뢠���� 䫠�� ��⠭����.
rem ���⢥��⢥���, ����� ��⠭�������� ���� �᫨ 㤠���� (��� ᥩ��), ���� �᫨ ���� 䫠��.
IF NOT "%SkipInstallsKeepQueue%"=="1" CALL "%~dp0_software_install_queued.cmd"

EXIT /B

:GetNameNoExt <var> <path>
(
    SET "%~1=%~n2"
EXIT /B
)
