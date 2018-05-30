@(REM coding:CP866
ECHO OFF
ECHO �����⮢�� ��䨫� ���짮��⥫� � ��ࢮ�� ������, ��������.
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
    SET "srcpath=%~dp0"
    SET "RegTmpDir=%TEMP%\%~n0-reg"
    rem IF NOT DEFINED DefaultsSource EXIT /B 32010
    
    IF /I "%USERNAME%"=="�த����" SET "RemoveAllAppX=1"
    IF /I "%USERNAME%"=="���짮��⥫�" SET "RemoveAllAppX=1"
    IF /I "%USERNAME%"=="Install" SET "RemoveAllAppX=1"
    
    CALL :CheckTempProfile "%USERPROFILE%" || (
	ECHO �室 � ��⥬� �믮���� � �६���� ��䨫��, �� ��室� �� ��������� ���� �����!
	PAUSE
    )
)
:GetDefaultconfigDirAgain
CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
CALL :GetDir configDir "%DefaultsSource%"
(
    CALL "%configDir%_Scripts\find7zexe.cmd"
    FOR %%A IN ("\\Srv0.office0.mobilmir\profiles$\Share\config\Users\Default\AppData\Local\mobilmir.ru" "%configDir%Users\Default\AppData\Local\mobilmir.ru" "%LOCALAPPDATA%\mobilmir.ru" "%USERPROFILE%\..\Default\AppData\Local\mobilmir.ru" "%SystemDrive%\Users\Default\AppData\Local\mobilmir.ru") DO IF EXIST "%%~A\DefaultUserRegistrySettings.7z" (
	SET "regDfltNewUser=%%~A\DefaultUserRegistrySettings.7z"
	SET "dirNewUserDefaults=%%~A"
	GOTO :NewUserDefaultsFound
    )
    ECHO �� ������� ����� � ����ன���� �� 㬮�砭��.
    ECHO ������ ���� �������, �⮡� ������� ����, ��� ���ன� ����, �⮡� �⫮����.
    PAUSE>NUL
    GOTO :GetDefaultconfigDirAgain
)
:NewUserDefaultsFound
IF NOT DEFINED AutoHotkeyExe CALL "%configDir%_Scripts\FindAutoHotkeyExe.cmd"
(
    IF EXIST "%regDfltNewUser%" (
	IF DEFINED exe7z %exe7z% x -o"%RegTmpDir%" -- "%regDfltNewUser%"
	FOR /R %%I IN ("%RegTmpDir%\*.reg") DO REG IMPORT "%%~fI"
	RD /S /Q "%RegTmpDir%"
	IF NOT "%regDfltNewUser:~0,2%"=="\\" DEL "%regDfltNewUser%"
    )
    IF DEFINED RemoveAllAppX (
	START "�������� ��� Metro-�ਫ������" %comspec% /C ""%configDir%_Scripts\cleanup\AppX\Remove All AppX Apps for current user.cmd" /firstlogon"
    ) ELSE (
	START "�������� Metro-�ਫ������, �஬� ࠧ�襭���" %comspec% /C ""%configDir%_Scripts\cleanup\AppX\Remove AppX Apps except allowed.cmd" /firstlogon"
    )
    
    FOR /F "usebackq delims=" %%A IN (`DIR /S /B /O "%dirNewUserDefaults%\RunOnce\"`) DO (
	IF /I "%%~xA"==".cmd" (
	    START "" /B /WAIT %comspec% /C "%%~A"
	) ELSE IF /I "%%~xA"==".ahk" (
	    %AutohotkeyExe% "%%~fA"
	) ELSE (
	    START "" "%%~fA"
	)
    )
    
    IF NOT ERRORLEVEL 1 IF NOT "%srcpath:~0,2%"=="\\" DEL "%~f0"
    EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
:CheckTempProfile
SET "profileDirName=%~nx1"
(
    IF NOT DEFINED tempProfileDir (
	IF /I "%profileDirName%"=="TEMP" EXIT /B 1
	IF /I "%profileDirName:~0,5%"=="TEMP." EXIT /B 1
    )
    EXIT /B 0
)
