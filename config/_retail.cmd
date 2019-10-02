@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
%SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )

IF DEFINED PROCESSOR_ARCHITEW6432 "%SystemRoot%\SysNative\cmd.exe" /C "%0 %*" & EXIT /B
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
(
TITLE Initial config

rem SET "robocopyDcopy=DAT"
rem CALL "%~dp0_Scripts\CheckWinVer.cmd" 8 || SET "robocopyDcopy=T"
%AutoHotkeyExe% /ErrorStdOut "%~dp0_Scripts\GUI\AcquireAndRecordMailUserId.ahk"
IF NOT DEFINED instSoftUpdScripts CALL :Ask_SetupLocalDownloader
IF NOT DEFINED Inst1S CALL :AskAbout1S
)
IF "%Inst1S%"=="1" (
    %SystemRoot%\System32\NET.exe USER Продавец /ADD /passwordchg:no /passwordreq:no
    %SystemRoot%\System32\wbem\wmic.exe path Win32_UserAccount where Name='Продавец' set PasswordExpires=false
) ELSE (
    %SystemRoot%\System32\NET.exe USER Пользователь /ADD /passwordchg:no /passwordreq:no
    %SystemRoot%\System32\wbem\wmic.exe path Win32_UserAccount where Name='Пользователь' set PasswordExpires=false
)
(
START "Copying Drivers\Canon\Laser MF" %comspec% /C "%~dp0"
START "Добавление стандартных администраторов" %comspec% /C "%~dp0_Scripts\AddUsers\Add_Admins.cmd"

TITLE Writing DefaultsSource
IF NOT EXIST "%ProgramData%\mobilmir.ru" MKDIR "%ProgramData%\mobilmir.ru"
CALL "%~dp0_Scripts\copy_defaultconfig_to_localhost.cmd" Apps_dept.7z

TITLE Running _business_config.cmd
POWERCFG -h off & POWERCFG /H OFF
CALL "%~dp0_Scripts\_business_config.cmd"
rem REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Domain" /d "office0.mobilmir" /f
rem REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Domain" /d "office0.mobilmir" /f
)
:All
(
TITLE Running _all.cmd
CALL "%~dp0_all.cmd" %arg%
)
:AfterAll
(
TITLE AfterAll
START "Collecting inventory information with TeamViewer ID" /I %comspec% /C "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Inventory\collector-script\SaveArchiveReport.cmd"

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
    IF /I "%COMPUTERNAME:~-2%"=="-K" (
        ECHO Выключение спящего и ждущего режимов
        %SystemRoot%\System32\powercfg.exe -X -standby-timeout-ac 0
        %SystemRoot%\System32\powercfg.exe -X -standby-timeout-dc 0
        %SystemRoot%\System32\powercfg.exe -X -hibernate-timeout-ac 0
        %SystemRoot%\System32\powercfg.exe -X -hibernate-timeout-dc 0
        
        IF NOT DEFINED instSoftUpdScripts SET "instSoftUpdScripts=1"
    )
    IF NOT DEFINED instSoftUpdScripts CALL :Ask_SetupLocalDownloader
)
(
    IF /I "%instSoftUpdScripts%"=="1" (
        START "Установка скрипта авто-обновления ПО" %comspec% /C "%~dp0_Scripts\software_update_autodist\SetupLocalDownloader.cmd"
        START "Copying distributives" /MIN %comspec% /C "%~dp0_Scripts\CopyDistributives_AllSoft.cmd"
    )
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
rem IF NOT DEFINED Inst1S CALL :AskAbout1S
IF NOT "%Inst1S%"=="1" GOTO :Skip1SAndRelated
)
:r1SAndRelated
rem SET "RarusInstallScript=\\*.office0.mobilmir\1S\ShopBTS_InitialBase\_install_ask_parm.cmd"
rem (
rem     IF NOT EXIST "%RarusInstallScript%" (
rem 	ECHO Дистрибутив Рарус недоступен по стандартному пути [%RarusInstallScript%]. Укажите полный путь к файлу ShopBTS_InitialBase\_install_ask_parm.cmd
rem 	SET /P RarusInstallScript=^>
rem     )
rem     START "Installing Rarus" /I /WAIT %comspec% /C "%RarusInstallScript%"
rem )
:Skip1SAndRelated
(
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
    SET /P "Inst1S=Этот компьютер - касса? [1,y,д=да]"
    IF /I "%Inst1S:~0,1%"=="y" SET "Inst1S=1"
    IF /I "%Inst1S:~0,1%"=="д" SET "Inst1S=1"
EXIT /B
)
:Ask_SetupLocalDownloader
(
    ECHO /P "instSoftUpdScripts=Запустить установку скриптов автообновления ПО? [1=да]"
EXIT /B
)
