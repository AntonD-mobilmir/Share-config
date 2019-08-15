@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF DEFINED PROCESSOR_ARCHITEW6432 (
	"%SystemRoot%\SysNative\cmd.exe" /C %0 %*
	EXIT /B
    )
    ECHO OFF
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    IF NOT DEFINED AutohotkeyExe CALL "%~dp0..\FindAutoHotkeyExe.cmd" & REM only used in FSACL_Homedir.cmd
    IF NOT DEFINED SetACLexe CALL "%~dp0..\find_exe.cmd" SetACLexe SetACL.exe "%SystemDrive%\SysUtils\SetACL.exe"
    IF NOT DEFINED SetACLexe (
	ECHO SetACL.exe не найден, продолжение невозможно.
	EXIT /B 2
    )

    SET "UIDEveryone=S-1-1-0;s:y"
    SET "UIDAuthenticatedUsers=S-1-5-11;s:y"
    SET "UIDUsers=S-1-5-32-545;s:y"
    SET "UIDSYSTEM=S-1-5-18;s:y"
    SET "UIDCreatorOwner=S-1-3-0;s:y"
    SET "UIDAdministrators=S-1-5-32-544;s:y"

    rem IF /I "%~1" NEQ "/NoProfiles" FOR /F "usebackq skip=2 tokens=1,2*" %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" /v "ProfilesDirectory"`) DO IF "%%I"=="ProfilesDirectory" SET "ProfilesDirectory=%%~K"
    SET "ProfilesDirectory=D:\Users"
)
rem FOR /F "usebackq tokens=* delims=" %%I IN (`ECHO %ProfilesDirectory%`) DO SET "ProfilesDirectory=%%~I"
(
    rem %SetACLexe% -on "%ProfilesDirectory%" -ot file -actn clear -clr dacl -actn ace -ace "n:%UIDAuthenticatedUsers%;p:FILE_ADD_SUBDIRECTORY;i:np;m:set" -ignoreerr -silent
    FOR /D %%I IN ("%ProfilesDirectory%\*.*") DO CALL :AskIfToProcessHomeDir "%%~nxI" && CALL "%~dp0FSACL_Homedir.cmd" "%%~I"
    
    ECHO Разрешение чтения и выполнения для системных папок 
    CALL :MakeDirsReadOnlyForUsers "%UIDAuthenticatedUsers%" "%UIDUsers%"
    ECHO Разрешение чтения и выполнения для Thunderbird\AddressBook и Distributives
    CALL "%srcpath%FSACL_ReadExecute.cmd" "%UIDEveryone%" d:\Mail\Thunderbird\AddressBook D:\Distributives "%USERPROFILE%\BTSync\Distributives"
    ECHO Настройка доступа к стандартным общим папкам
    CALL "%srcpath%FSACL_PublicDirsRoot.cmd" "%ProfilesDirectory%\Public" "%ProfilesDirectory%\All Users" "%ProfilesDirectory%\Default User"
    ECHO Настройка доступа к d:\Mail\Thunderbird\profile
    CALL :ResetACL d:\Mail\Thunderbird\profile 
    CALL "%srcpath%FSACL_AdmFullUserModifyNoExecute.cmd" "%UIDAuthenticatedUsers%" d:\Mail\Thunderbird\profile 
    REM ECHO Разрешение записи и выполнения в "d:\Program Files"
    REM CALL "%srcpath%FSACL_Change.cmd" "%UIDAuthenticatedUsers%" "d:\Program Files"
    ECHO Настройка доступа к папке истории файлов
    CALL "%srcpath%FSACL_FileHistory.cmd"
EXIT /B
)

:MakeDirsReadOnlyForUsers
(
    CALL "%srcpath%FSACL_ReadExecute.cmd" %1 C:\ D:\ R:\ "%SystemRoot%\Temp" "%ALLUSERSPROFILE%\Documents" "%ALLUSERSPROFILE%\DRM" "%ALLUSERSPROFILE%\Application Data"
    IF "%~2"=="" EXIT /B
    SHIFT
GOTO :MakeDirsReadOnlyForUsers
)

:ResetACL
(
    IF EXIST "%~1" (
	%windir%\system32\takeown.exe /F %1 /R /A /D Y >NUL
	%SetACLexe% -on %1 -ot file -rec cont_obj -actn rstchldrn -rst dacl -ignoreerr -silent
    )
    SHIFT
    IF "%~2"=="" EXIT /B
    GOTO :ResetACL
)

:AskIfToProcessHomeDir
(
REM 0 = no error = yes, process
REM 1 = error = no, skip
    IF /I "%~1"=="Public" EXIT /B 1
    IF /I "%~1"=="All Users" EXIT /B 1
    IF /I "%~1"=="Default" EXIT /B 1
    IF /I "%~1"=="Default User" EXIT /B 1
    IF /I "%~1"=="Default User.org" EXIT /B 1
    IF /I "%~1"=="LocalService" EXIT /B 1
    IF /I "%~1"=="NetworkService" EXIT /B 1

    IF /I "%~1"=="Install" EXIT /B 1
    IF /I "%~1"=="admin-task-scheduler" EXIT /B 1
    IF /I "%~1"=="Admin" EXIT /B 1
    IF /I "%~1"=="Administrator" EXIT /B 1
    IF /I "%~1"=="Администратор" EXIT /B 1
    IF /I "%~1"=="LogicDaemon" EXIT /B 1
    IF /I "%~1"=="Anton.Derbenev" EXIT /B 1
    IF /I "%~1"=="diverse" EXIT /B 1
    IF /I "%~1"=="Karina.Razuvaeva" EXIT /B 1
    IF /I "%~1"=="Продавец" EXIT /B 0
    IF /I "%~1"=="Пользователь" EXIT /B 0
    IF /I "%~1"=="Гость" EXIT /B 0
    IF /I "%~1"=="Guest" EXIT /B 0
    
rem     IF "%RunInteractiveInstalls%"=="0" (
rem 	SET FileSystemUserHomePerm_%~1=1
rem     ) ELSE SET /P FileSystemUserHomePerm_%~1=Обработать %1 [1=да, остальное=нет]?
EXIT /B 0
)
