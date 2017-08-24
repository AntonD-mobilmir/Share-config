@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF DEFINED PROCESSOR_ARCHITEW6432 "%SystemRoot%\SysNative\cmd.exe" /C %0 %* & EXIT /B
SETLOCAL ENABLEEXTENSIONS
SET "configDir=%~dp0"
CALL "%~dp0_Scripts\Lib\.utils.cmd" CheckSetSystemVars
CALL "%~dp0_Scripts\FindAutoHotkeyExe.cmd"
IF NOT DEFINED exe7z CALL "%~dp0_Scripts\find7zexe.cmd" || PAUSE
IF NOT DEFINED xlnexe CALL "%~dp0_Scripts\find_exe.cmd" xlnexe xln.exe || PAUSE
)
(
%AutohotkeyExe% "%~dp0_Scripts\EjectCDDrivesIfNotEmpty.ahk"
rem @ECHO Если компьютер в офисе, на время настройки стоит указать офисный прокси
rem rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,,4
)
:restart
IF NOT EXIST D:\ ECHO Driveletter D: [Data] not accessible & PAUSE & GOTO :restart
IF NOT EXIST R:\ ECHO Driveletter R: [Backup] not accessible & PAUSE & GOTO :restart

rem CALL "%~dp0_Scripts\FindSoftwareSource.cmd"
rem Dirty way to get paths in any situation
rem SET PATH=%PATH%;%ProgramData%\mobilmir.ru\Common_Scripts;%SystemDrive%\SysUtils;%SystemDrive%\SysUtils\gnupg;%SystemDrive%\SysUtils\lbrisar;%SystemDrive%\SysUtils\libs;%SystemDrive%\SysUtils\libs\OpenSSL;%SystemDrive%\SysUtils\libs\OpenSSL\bin;%SystemDrive%\SysUtils\ResKit;%SystemDrive%\SysUtils\SysInternals;%SystemDrive%\SysUtils\UnxUtils;%SystemDrive%\SysUtils\UnxUtils\Uri

REM parsing command line arguments
SET "arg=%~1"
SET "argflag=%arg:~,1%"
SET "argvalue=%arg:~1%"
IF /I "%argflag%"==":" (
    SHIFT /1
    SET "arg="
    GOTO :%argvalue%
)

TITLE Initial config
%AutoHotkeyExe% /ErrorStdOut "%~dp0_Scripts\GUI\AcquireAndRecordMailUserId.ahk"
IF NOT DEFINED instBTSyncandSoftUpdScripts CALL :AskAboutBTSync
IF NOT DEFINED Inst1S CALL :AskAbout1S
IF "%Inst1S%"=="1" (
    NET USER Продавец /ADD /passwordchg:no /passwordreq:no
    wmic path Win32_UserAccount where Name='Продавец' set PasswordExpires=false
) ELSE (
    NET USER Пользователь /ADD /passwordchg:no /passwordreq:no
    wmic path Win32_UserAccount where Name='Пользователь' set PasswordExpires=false
)
(
START "" control userpasswords2

TITLE Writing DefaultsSource
IF NOT EXIST "%ProgramData%\mobilmir.ru" MKDIR "%ProgramData%\mobilmir.ru"
CALL "%~dp0_Scripts\copy_defaultconfig_to_localhost.cmd" Apps_dept.7z

TITLE Running _business_config.cmd
POWERCFG -h off & POWERCFG /H OFF
CALL "%~dp0_Scripts\_business_config.cmd"
WMIC computersystem where name="%COMPUTERNAME%" call joindomainorworkgroup name="OFFICE0"
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Domain" /d "office0.mobilmir" /f
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Domain" /d "office0.mobilmir" /f
)
:All
(
TITLE Running _all.cmd
CALL "%~dp0_all.cmd" %arg%
)
:AfterAll
(
TITLE AfterAll
START "Collecting inventory information with TeamViewer ID" /I %comspec% /C "\\Srv0\profiles$\Share\Inventory\collector-script\SaveArchiveReport.cmd"

rem Without running ahk as an app (just starting .ahk), START /I misbehaves, ignoring the switch
CALL "%~dp0_Scripts\FindAutoHotkeyExe.cmd"
CALL "%~dp0_Scripts\ChangeNXOptInToOptOut.cmd"
CALL "%~dp0_Scripts\defrag in background.cmd"
)
:SchTasks
(
TITLE SchTasks
CALL "%~dp0_Scripts\Tasks\remove_old_Windows_Backups.cmd"
SET "srcpath="
)
:PageFile
(
TITLE PageFile
IF EXIST c:\WINDOWS\SwapSpace CALL "%~dp0_Scripts\pagefile_on_Windows_SwapSpace.cmd"
SET "srcpath="
)
:PrepareProfiles
(
TITLE PrepareProfiles
CALL "%~dp0_Scripts\HideShortcutsInAllUsersStartMenu.cmd"
CALL "%~dp0_Scripts\copyDefaultUserProfile.cmd"
REM Unpacking Desktop Shortcuts / Распаковка ярлыков на рабочий стол 
CALL "%~dp0_Scripts\unpack_retail_files_and_desktop_shortcuts.cmd"
rem Изменение пути профилей
MKDIR d:\Users
IF EXIST d:\Users %AutohotkeyExe% "%~dp0_Scripts\MoveUserProfile\SetProfilesDirectory_D_Users.ahk"

rem TODO: не работает, если запускать "!run without installing soft.cmd"
REM Копирование дистрибутивов, поскольку новые отделы не подключены к офисной сети
START "Copying distributives" /MIN %comspec% /C "%~dp0_Scripts\CopyDistributives_AllSoft.cmd"
rem START "Установка depts-commands\execscripts" %comspec% /C "\\AcerAspire7720g\Projects\depts-commands\execscripts\install.cmd"
)
:MTMail
(
REM path workaround:
SET "PATH=%PATH%;C:\SysUtils\libs"

rem TODO: не работает, если запускать "!run without installing soft.cmd"
REM скрипт создания п/я вылетает
START "" /B /WAIT %comspec% /C "%~dp0_Scripts\CreateMTProfileForSharedUser.cmd"
rem ECHO ---Отладка---
rem ECHO Только что должен быть создаться общий профиль Thunderbird.
rem PAUSE
)
:skipMTMail
(
REM Install 1S
IF NOT DEFINED Inst1S CALL :AskAbout1S
IF NOT "%Inst1S%"=="1" GOTO :Skip1SAndRelated
)
:r1SAndRelated
(
    SET "RarusInstallScript=\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\_install_ask_parm.cmd"
    IF NOT EXIST "%RarusInstallScript%" (
	ECHO Дистрибутив Рарус недоступен по стандартному пути [%RarusInstallScript%]. Укажите полный путь к файлу ShopBTS_InitialBase\_install_ask_parm.cmd
	SET /P RarusInstallScript=^>
    )
    START "Installing Rarus" /I /WAIT %comspec% /C "%RarusInstallScript%"
)
:Skip1SAndRelated
(
IF NOT DEFINED instBTSyncandSoftUpdScripts CALL :AskAboutBTSync
IF /I "%instBTSyncandSoftUpdScripts%"=="1" (
    START "Установка скрипта авто-обновления ПО" %comspec% /C "%~dp0_Scripts\software_update_autodist\SetupLocalDownloader.cmd"
    START "Установка скиптов BTSync" %comspec% /C "\\AcerAspire7720G\Projects\BTSync\Install_BTSync.cmd"
)

ECHO Скрипт завершил работу. Окно остаётся открыто для просмотра журнала. & PAUSE & EXIT /B
)
:AskAbout1S
(
    IF "%COMPUTERNAME:~-2,1%"=="-" (
	IF /I "%COMPUTERNAME:~-1%"=="K" (
	    SET "Inst1S=1"
	    EXIT /B
	) ELSE IF %COMPUTERNAME:~-1% GEQ 0 IF %COMPUTERNAME:~-1% LEQ 9 (
	    SET "Inst1S=0"
	    EXIT /B
	)
    )
    SET /P "Inst1S=Устанавливать 1С-Рарус? [1=да]"
    IF /I "%Inst1S:~0,1%"=="y" SET "Inst1S=1"
    IF /I "%Inst1S:~0,1%"=="д" SET "Inst1S=1"
EXIT /B
)
:AskAboutBTSync
(
    ECHO /P "instBTSyncandSoftUpdScripts=Запустить установку BTSync и скриптов автообновления ПО? [1=да]"
EXIT /B
)
