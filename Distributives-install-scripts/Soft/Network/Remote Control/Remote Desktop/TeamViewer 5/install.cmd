@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF NOT DEFINED debug ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF NOT DEFINED ErrorCmd (
    IF NOT "%RunInteractiveInstalls%"=="0" (
	SET "ErrorCmd=PAUSE"
    ) ELSE (
	SET "ErrorCmd=CALL :EchoErrorLevel"
    )
)
SET "scriptName=%~n0"
IF "%~1"=="/CmdRestarted" (
    SHIFT
) ELSE IF /I %PROCESSOR_ARCHITECTURE% NEQ x86 (
    ECHO Restarting with 32-bit cmd.exe
    "%SystemRoot%\SysWOW64\cmd.exe" /C ""%~f0" /CmdRestarted %*"
    EXIT /B
)
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
)
@(
    REM -- some settings
    SET "TempDirName=TeamViewer_Setup"
    SET "DistributivesArchive=%srcpath%TeamViewerMSI.zip"
    SET "SettingsScript=settings.cmd"
    SET "MSIlog=%TEMP%\%scriptName%.log"

    IF NOT DEFINED exe7z CALL :find7zexe
)
(
    SET "TempExtractPath=%TEMP%\%TempDirName%"
    IF [%exe7z%]==[""] SET "exe7z="
    IF NOT DEFINED exe7z (
	ECHO 7-Zip не найден скриптом установки TeamViewer, возможна только локальная установка вручную.
	ECHO Все параметры командной строки игнорируются.
	%ErrorCmd%
	GOTO :LocalInstallNonZipped
    )
)
:readCmdlArgs
IF /I "%~x1"==".MSI" (
    IF "%~2"=="" (
	SET "InstallMSI=%~1"
	SET "RegConfigName=%~n1.reg"
    ) ELSE (
	SET "InstallMSI=%~1"
	SET "RegConfigFullPath=%~2"
	SET "RegConfigName=%~nx2"
    )
) ELSE (
    IF "%~2"=="" (
	IF "%~1"=="" (
	    IF "%InstallMSI%"=="" CALL :SelectInstallMSI
	) ELSE (
	    IF DEFINED desthost ECHO desthost переопределён, предыдущее значение: %desthost%; новое значение: %2
	    SET "desthost=%~1"
	    SET "InstallMSI=TeamViewer_Host.MSI"
	    SET "RegConfigName=TeamViewer_host.reg"
	)
    ) ELSE (
	IF DEFINED desthost ECHO desthost переопределён, предыдущее значение: %desthost%; новое значение: %2
	SET "desthost=%~1"
	SHIFT
	GOTO :readCmdlArgs
    )
)
IF DEFINED desthost CALL :SetDesthostVars || EXIT /B 1
(
    IF "%RegConfigFullPath%"=="%RegConfigName%" SET "RegConfigFullPath="
    SET "PreExeCcmd="
    IF NOT EXIST "%TempExtractPath%" MKDIR "%TempExtractPath%"
    ECHO Начало установки TeamViewer.
    ECHO Временная папка: %TempExtractPath%
    PUSHD "%TempExtractPath%" || (ECHO Не удалось перейти в папку "%TempExtractPath%"& GOTO :ExitWithError)

    IF DEFINED RemoveMSI SET quotedRemoveMSI="%RemoveMSI%"
)
(
    ECHO Архив с дистрибутивами: %DistributivesArchive%
    ECHO MSI для установки: %InstallMSI%
    ECHO Скрипт настроек: %SettingsScript%
    IF DEFINED RemoveMSI ECHO MSI для удаления: %RemoveMSI%
    %exe7z% e -y -aoa -- "%DistributivesArchive%" "%InstallMSI%" %quotedRemoveMSI%||%ErrorCmd%
    COPY /B /Y "%srcpath%PostFormData.ahk"
    COPY /B /Y "%srcpath%%SettingsScript%"
    IF DEFINED RegConfigFullPath (
	ECHO reg-файл с настройками: %RegConfigFullPath%
	COPY /B /Y "%RegConfigFullPath%"
    ) ELSE (
	IF DEFINED DefaultsSource (
	    ECHO Архив настроек: %DefaultsSource%
	    ECHO reg-файл с настройками: %RegConfigName%
	    IF EXIST "%DefaultsSource%" %exe7z% e -y -aoa -- "%DefaultsSource%" "TeamViewer\%RegConfigName%"||(
		%ErrorCmd%
		CALL :SetErrVar RegConfigName "%DefaultsSource% 7-Zip extract error" ", fallback to TeamViewer_host.defaults.reg"
	    )
	)
	IF NOT EXIST "%RegConfigName%" (
	    ECHO reg-файл с настройками не распаковался. Будет использован TeamViewer_host.defaults.reg.
	    COPY /B /Y "%srcpath%TeamViewer_host.defaults.reg" "%RegConfigName%"
	)
    )
    %SystemRoot%\System32\SC.exe %remotesystem% STOP TeamViewer5
    %SystemRoot%\System32\ping.exe 127.0.0.1 -n 5 >NUL 2>&1
    IF NOT DEFINED RemoveMSI GOTO :skipRemoveMSI
    %PreExeCcmd% cmd.exe /C ""%SettingsScript%" /CleanupBeforeReinstall"
)
:retryMsiExecUninstall
(
    FOR %%A IN ("{118F5245-1999-4227-A12D-A0BB69A5E80B}" "{464CA7EE-BD7E-496F-9054-7E4E87AF12E3}" %RemoveMSI%) DO (
        %PreExeCcmd% msiexec.exe /x "%%~A" /qn REBOOT=ReallySuppress /log+ "%MSILog%"
        IF ERRORLEVEL 1618 IF NOT ERRORLEVEL 1619 ( %SystemRoot%\System32\ping.exe 127.0.0.1 -n 30 >NUL & GOTO :retryMsiExecUninstall ) & rem another install in progress, wait and retry
    )
    IF ERRORLEVEL 1 SET "showlog=1"
    %PreExeCcmd% "C:\Program Files\Teamviewer\Version5\uninstall.exe" -silent
    %PreExeCcmd% "C:\Program Files (x86)\Teamviewer\Version5\uninstall.exe" -silent
    
    %SystemRoot%\System32\ping.exe 127.0.0.1 -n 5 >NUL 2>&1
)
:skipRemoveMSI
(
    FOR %%A IN (TeamViewer_Service.exe TeamViewer.exe) DO %SystemRoot%\System32\taskkill.exe %taskkillRmt% /F /IM %%A
    %PreExeCcmd% cmd.exe /C ""%SettingsScript%" "%RegConfigName%""
)
:retryMsiExecFixAll
(
    %PreExeCcmd% msiexec.exe /fa "%InstallMSI%" /quiet REBOOT=ReallySuppress /log+ "%MSILog%"
    IF ERRORLEVEL 1618 IF NOT ERRORLEVEL 1619 ( %SystemRoot%\System32\ping.exe 127.0.0.1 -n 30 >NUL & GOTO :retryMsiExecFixAll ) & rem another install in progress, wait and retry
)
:retryMsiExecInstall
(
    %PreExeCcmd% msiexec.exe /i "%InstallMSI%" /quiet REBOOT=ReallySuppress /log+ "%MSILog%"
    IF ERRORLEVEL 1618 IF NOT ERRORLEVEL 1619 ( %SystemRoot%\System32\ping.exe 127.0.0.1 -n 30 >NUL & GOTO :retryMsiExecInstall ) & rem another install in progress, wait and retry
    IF ERRORLEVEL 1 SET "showlog=1"
    %PreExeCcmd% cmd.exe /C ""%SettingsScript%" /PostInstall "%RegConfigName%""
)
(
    IF DEFINED showlog (
	IF "%RunInteractiveInstalls%"=="0" (
	    TYPE "%MSILog%"
	) ELSE (
	    IF EXIST "%MSILog%" notepad "%MSILog%"
	)
    )
    DEL "%MSIlog%"
POPD

SET v=0
)
:retryRDTempExtrPath
(
RD /S /Q "%TempExtractPath%"
IF EXIST "%TempExtractPath%" IF %v% LSS 10 (
    %SystemRoot%\System32\ping.exe 127.0.0.1 -n 5 >NUL
    SET /A v+=1
    GOTO :retryRDTempExtrPath
)
EXIT /B
)
:ExitWithError
(
    ECHO Ошибка при установке
    %ErrorCmd%
EXIT /B
)
:SelectInstallMSI
    SET "listtemp=%temp%\%scriptName%.%RANDOM%list.tmp"
    (
    IF EXIST "%listtemp%" DEL "%listtemp%"
    IF EXIST "%listtemp%" ECHO "%listtemp%" не должен существовать. & EXIT /B 2
    %exe7z% l -- "%DistributivesArchive%" *.MSI>"%listtemp%"
    FOR /F "usebackq tokens=1 EOL=- delims=[]" %%I IN (`%SystemRoot%\System32\find.exe /n "------------------- ----- ------------ ------------  ------------------------" "%listtemp%"`) DO (
	SET "skiplines=%%I"
	GOTO :ExitForFindSplitter
    )
:ExitForFindSplitter
    SET "Counter=0"
    ECHO Доступны следующие варианты установки:
    ECHO 0 : Удалить TeamViewer_Host.msi, установить TeamViewer.msi
    )
    FOR /F "usebackq skip=%skiplines% tokens=5* delims= " %%A IN ("%listtemp%") DO (
	IF "%%~A"=="------------------------" GOTO :SelectInstallMSIExitFor
	SET /A "Counter+=1"
	CALL :AddMSIToList "%%~B"
    )
:SelectInstallMSIExitFor
(
    DEL "%listtemp%"
    
    SET /P "MSINum=Выбранный вариант:"
    REM MSINum defined above
)
(
    IF "%MSINum%"=="0" (
        SET "RemoveMSI=TeamViewer_Host.msi"
        SET "InstallMSI=TeamViewer.msi"
        SET "RegConfigName=TeamViewer.reg"
    ) ELSE (
        FOR /F "usebackq delims=" %%I IN (`ECHO %%MSI%MSINum%%%`) DO (
            SET "InstallMSI=%%I"
            SET "RegConfigName=%%~nI.reg"
        )
    )
EXIT /B
)
:AddMSIToList
(
    SET "MSI%Counter%=%~1"
    ECHO %Counter% : %~1
EXIT /B
)
:LocalInstallNonZipped
(
ECHO 1. TeamViewer_Setup.exe
ECHO 2. TeamViewer_Host_Setup.exe
ECHO Любой другой вариант - выход
SET /P "InstallNum=: "
)
(
IF "%InstallNum%"=="1" START "" "%srcpath%TeamViewer_Setup.exe" /s
IF "%InstallNum%"=="2" START "" "%srcpath%TeamViewer5HostUnattended_egs.exe"
EXIT /B
)
:SetDesthostVars
(
    CALL :findexe wgetexe wget.exe c:\SysUtils\wget.exe || EXIT /B 1
    SET "TempExtractPath=%remotesystem%\Admin$\Temp\%TempDirName%"
    IF "%desthost:~0,2%"=="\\" SET "desthost=%desthost:~2%"
)
(
    SET "taskkillRmt=/S %desthost%"
    SET "remotesystem=\\%desthost%"
    IF DEFINED wgetexe (
	START "" /B /WAIT /D"%TEMP%" %wgetexe% -N --no-check-certificate http://live.sysinternals.com/psexec.exe || EXIT /B 1
	SET PreExecCmd="%TEMP%\psexec.exe" %remotesystem% -accepteula -nobanner -w "%SystemRoot%\Temp\%TempDirName%"
    )
EXIT /B
)
:EchoErrorLevel
(
    ECHO ErrorLevel: %ErrorLevel%
EXIT /B
)
:SetErrVar <varname> <prefix> <suffix>
(
    SET "%~1=%2%ERRORLEVEL%%3"
EXIT /B
)
:find7zexe
(
    FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command" /ve`) DO CALL :checkDirFrom1stArg %%B && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CURRENT_USER\Software\7-Zip" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\7-Zip" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString"`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString" /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B

    CALL :findexe exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL :findexe exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" || (ECHO  & EXIT /B 9009)

EXIT /B
)
:checkDirFrom1stArg <arg1> <anything else>
(
    CALL :Check7zDir "%~dp1"
EXIT /B
)
:Check7zDir <dir>
    IF NOT "%~1"=="" SET "dir7z=%~1"
    IF "%dir7z:~-1%"=="\" SET "dir7z=%dir7z:~0,-1%"
(
    IF NOT EXIST "%dir7z%\7z.exe" EXIT /B 9009
    "%dir7z%\7z.exe" <NUL >NUL 2>&1 || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
    SET exe7z="%dir7z%\7z.exe"
EXIT /B
)
:findexe
    (
    SET "locvar=%~1"
    SET "seekforexecfname=%~nx2"
    )
    (
    FOR /D %%I IN ("%~dp2") DO IF EXIST "%%~I%seekforexecfname%" CALL :testexe %locvar% "%%~I%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% %2 & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED srcpath CALL :testexe %locvar% "%srcpath%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED utilsdir CALL :testexe %locvar% "%utilsdir%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    FOR /R "%SystemDrive%\SysUtils" %%I IN (.) DO IF EXIST "%%~I\%seekforexecfname%" CALL :testexe %locvar% "%%~I\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "%srcpath%..\..\..\..\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\localhost\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    )
    :findexeNextPath
    (
	IF "%~3"=="" GOTO :testexe
	IF EXIST "%~3" FOR %%I IN ("%~3") DO CALL :testexe %locvar% "%%~I" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
	SHIFT /3
    GOTO :findexeNextPath
    )
    :testexe
    (
	IF "%~2"=="" EXIT /B 9009
	IF NOT EXIST "%~dp2" EXIT /B 9009
	"%~2" %findExeTestExecutionOptions% <NUL >NUL 2>&1
	IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
	SET %~1="%~2"
EXIT /B
    )
