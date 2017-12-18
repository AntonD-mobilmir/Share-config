:restart
@(REM coding:CP866
    REM Script installs software_update download scripts
    REM and creates scheduler task locally
    REM by LogicDaemon <www.logicdaemon.ru>
    REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    ECHO OFF
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    IF NOT DEFINED ErrorCmd SET "ErrorCmd=@(ECHO  & (PING 127.0.0.1 -n 30 >NUL) & EXIT /B 32767)"

    REM following path is hardcoded inside Update_Distributives.job and in a lot of cmd scripts.
    SET "InstDest=d:\Scripts"
    REM Distributives are hardcoded in Distributives_Update_Run.cmd as "%~d0\Distributives"
    SET "DistDst=d:\Distributives"
    SET "UIDEveryone=S-1-1-0;s:y"
    SET "UIDAuthenticatedUsers=S-1-5-11;s:y"
    SET "UIDUsers=S-1-5-32-545;s:y"
    SET "UIDSYSTEM=S-1-5-18"
    
    FOR /F "usebackq tokens=2*" %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "SUSHost=%%J"
    
    IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
    CALL :ensureRsyncReady
    IF NOT DEFINED SetACLexe CALL "%~dp0..\find_exe.cmd" SetACLexe "%SystemDrive%\SysUtils\SetACL.exe" || GOTO :SysutilsFail

    rem без следующей строки на чистых Windows появляется:
    rem # sed.exe - Системная ошибка
    rem Запуск программы невозможен, так как на компьютере отсутствует libintl3.dll. Попробуйте переустановить программу. 
    SET "PATH=%PATH%;%SystemDrive%\SysUtils\libs"
    
    IF NOT DEFINED sedexe CALL "%~dp0..\find_exe.cmd" sedexe "%SystemDrive%\SysUtils\UnxUtils\sed.exe" || GOTO :SysutilsFail
    IF NOT DEFINED AutohotkeyExe CALL "%~dp0..\FindAutoHotkeyExe.cmd"
)
(
    IF NOT EXIST "%InstDest%" MKDIR "%InstDest%" || (
	ECHO Не удалось создать папку %InstDest%. Продолжение установки невозможно.
	%ErrorCmd%
	EXIT /B
    )
    "%SystemRoot%\System32\schtasks.exe" /End /TN "mobilmir\Update_Distributives" /F
    "%SystemRoot%\System32\schtasks.exe" /End /TN "mobilmir.ru\Update_Distributives" /F
    DEL /S /Q "%InstDest%\software_update\scripts\!*.*"
    DEL /S /Q "%InstDest%\software_update\scripts\_*.*"

    %exe7z% x -aoa -o"%InstDest%" -- "%~dp0downloader-dist.7z" || %ErrorCmd%
    %exe7z% x -aoa -o"%InstDest%\software_update" -- "%~dp0software_update.7z" || %ErrorCmd%
    IF EXIST "%InstDest%\logs.bak" RD /S /Q "%InstDest%\logs.bak"
    IF EXIST "%InstDest%\logs" MOVE "%InstDest%\logs" "%InstDest%\logs.bak"
    MKDIR "%InstDest%\logs" || %ErrorCmd%
    CALL :CheckCreateDir "%InstDest%\software_update\status" || %ErrorCmd%
    %SetACLexe% -on "%InstDest%\software_update\status" -ot file -actn ace -ace "n:%UIDEveryone%;p:change"
    CALL :CheckCreateDir "%InstDest%\software_update\old\status" || %ErrorCmd%
    %SetACLexe% -on "%InstDest%\software_update\old\status" -ot file -actn ace -ace "n:%UIDEveryone%;p:change"

    IF NOT DEFINED schedUserName CALL "%~dp0..\AddUsers\AddUser_admin-task-scheduler.cmd" /LeaveExistingPwd
    IF NOT DEFINED schedUserName CALL :GetCurrentUserName schedUserName
)
:addTask
SET "schtaskPassSw=" & IF DEFINED schedUserPwd SET schtaskPassSw=/RP "%schedUserPwd%"
IF NOT DEFINED schedUserName SET /P "schedUserName=Имя пользователя для задачи обновления дистрибутивов: "
(
SET "retaskq=0"
CALL "%~dp0..\CheckWinVer.cmd" 6 || ( CALL :SchTasksXP & GOTO :checkSchtasksError )
IF NOT ERRORLEVEL 1 (
    rem "%SystemRoot%\System32\schtasks.exe" /Delete /TN "mobilmir\Update_Distributives" /F
    "%SystemRoot%\System32\schtasks.exe" /Create /TN "mobilmir.ru\Update_Distributives" /XML "%~dp0Update_Distributives.xml" /RU "%schedUserName%" %schtaskPassSw% /NP /F
)
)
:checkSchtasksError
IF ERRORLEVEL 1 (
    SET "schedUserName="
    SET /P "retaskq=Код ошибки: %ERRORLEVEL%. Повторить? [1=Y]"
)
IF NOT DEFINED configDir CALL :getconfigDir
(
IF "%retaskq%"=="1" GOTO :addTask
IF /I "%retaskq:~0,1%"=="y" GOTO :addTask
%SetACLexe% -on "%InstDest%" -ot file -actn ace -ace "n:%schedUserName%;s:n;p:change"
%SystemRoot%\System32\takeown.exe /F "d:\Distributives" /A /R /D Y
%SetACLexe% -on "d:\Distributives" -ot file -actn ace -ace "n:%schedUserName%;s:n;p:change"
%SetACLexe% -on "%USERPROFILE%\BTSync\Distributives" -ot file -actn ace -ace "n:%schedUserName%;s:n;p:change"

%sedexe% -i "s/"{$SUSHost$}/"%SUSHost%/g" "%InstDest%\software_update\_install\dist\_get_SoftUpdateScripts_source.cmd" || %ErrorCmd%

START "install_software_update_scripts.cmd" /MIN %comspec% /C "%InstDest%\software_update\_install\install_software_update_scripts.cmd"

ECHO N|%SystemRoot%\System32\net.exe SHARE "Distributives" /DELETE
%SystemRoot%\System32\net.exe SHARE "Distributives=d:\Distributives"
ECHO Y|%SystemRoot%\System32\net.exe SHARE "SoftUpdateScripts$" /DELETE
%SystemRoot%\System32\net.exe SHARE "SoftUpdateScripts$=%InstDest%\software_update" /GRANT:Everyone,CHANGE
%SystemRoot%\System32\net.exe SHARE "SoftUpdateScripts$=%InstDest%\software_update" /GRANT:Все,CHANGE
%SystemRoot%\System32\net.exe SHARE "SoftUpdateScripts$=%InstDest%\software_update"

CALL :updateSysUtils

CALL :checkProxy
START "Copying download-scripts" /MIN %comspec% /C "%~dp0..\CopyDistributives_Downloaders.cmd"

IF NOT ERRORLEVEL 1 FOR %%I IN ("%~dp0downloader-dist.7z") DO (
    (ECHO %%~tI)>"%InstDest%\ver.flag"
    SET "instVersion=%%~tI"
)

ECHO Готово.
ECHO.
ECHO Отправка информации в форму...

CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
IF NOT DEFINED MailUserId SET "MailUserId=%COMPUTERNAME%"
)
(
ECHO "MailUserId=%MailUserId%"
ECHO "instVersion=%instVersion%"
FOR /F "usebackq delims=" %%A IN ("%~dp0..\pseudo-secrets\%~nx0.txt") DO (
    START "" %AutohotkeyExe% "%~dp0..\Lib\PostGoogleFormWithPostID.ahk" "%%~A" "entry.435608024=" "entry.1052111258=%MailUserId%" "entry.1449295455=%instVersion%"
    EXIT /B
)

EXIT /B
)
:CheckCreateDir
(
    IF NOT EXIST "%~1" MKDIR "%*"
EXIT /B
)
:SchTasksXP
(
    rem 2K-XP mode
    TYPE NUL
    COPY /B "%~dp0Update_Distributives.job" "%SystemRoot%\Tasks\*.*"
    SET "repeat=0"
)
    %SystemRoot%\System32\SCHTASKS.exe /Change /TN Update_Distributives /RU "%schedUserName%" /RP "%schedUserPwd%"|| SET /P "repeat=Произошла ошибка. Повторить? [1=y=да]"
(
    IF "%repeat%"=="1" GOTO :SchTasksXP
    IF /I "%repeat:~0,1%" EQU "y" GOTO :SchTasksXP
    IF /I "%repeat:~0,1%" EQU "д" GOTO :SchTasksXP
EXIT /B
)
:ensureRsyncReady
(
    CALL :rsyncFileCheck "%SystemDrive%\SysUtils\cygwin" rsync.exe cyggcc_s-1.dll cygiconv-2.dll cygpath.exe cygwin1.dll rsync.exe
    EXIT /B
)
:rsyncFileCheck
(
    IF "%~1"=="" EXIT /B 1
    IF "%~2"=="" EXIT /B
    IF NOT EXIST "%~1\%~2" GOTO :rsyncUnpack
    SHIFT /2
    GOTO :rsyncFileCheck
)
:rsyncUnpack
    SET "rsyncDistRelpath=Soft\PreInstalled\auto\SysUtils\SysUtils_rsync.7z"
(
    IF EXIST "%DistDst%\%rsyncDistRelpath%" (
	%exe7z% x -y -o%SystemDrive%\SysUtils -- "%DistDst%\%rsyncDistRelpath%"
    ) ELSE (
	%exe7z% x -y -o%SystemDrive%\SysUtils -- "\\Srv0.office0.mobilmir\Distributives\%rsyncDistRelpath%"
    )
    EXIT /B
)
:GetCurrentUserName <varname>
    IF NOT DEFINED whoamiexe CALL "%~dp0..\find_exe.cmd" whoamiexe "%SystemDrive%\SysUtils\UnxUtils\whoami.exe"
(
    FOR /F "usebackq delims=\ tokens=2" %%I IN (`%whoamiexe%`) DO SET "%~1=%%~I"
    IF NOT DEFINED %~1 SET "%~1=%USERNAME%"
    EXIT /B
)
:checkProxy
(
    IF NOT DEFINED http_proxy EXIT /B
    IF "%http_proxy%"=="http://127.0.0.1:3128/" EXIT /B
)
(
    %AutohotkeyExe% "%~dp0..\SetProxy.ahk" ""
    EXIT /B
)
:getconfigDir
(
    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd" || (CALL "%~dp0..\copy_defaultconfig_to_localhost.cmd" "%~dp0..\..\nul" & GOTO :getconfigDir)
    IF NOT DEFINED DefaultsSource (
	SET "DefaultsSource=%~dp0..\..\nul"
	ECHO Не удалось найти или скопировать _get_defaultconfig_source.cmd. Скрипты обновления установятся, но без этого файла работать не будут.
	%ErrorCmd%
    )
)
(
    CALL :GetDir configDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
    EXIT /B
)
:SysutilsFail
(
    CALL :updateSysUtils||EXIT /B
    GOTO :restart
)
:updateSysUtils
(
IF NOT DEFINED configDir CALL :getconfigDir
IF DEFINED SysutilsUpdated EXIT /B 32767
SET "SysutilsUpdated=1"
CALL :ensureRsyncReady
ECHO Waiting for PreInstalled to be copied...
)
(
( %comspec% /C ""%configDir%_Scripts\rSync_DistributivesFromSrv0.cmd" "D:\Distributives\Soft\PreInstalled"" ) && GOTO :distSysUtilsUpdated
XCOPY "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled" "D:\Distributives\Soft\PreInstalled" /D /E /C /I /H /K /Y && GOTO :distSysUtilsUpdated
EXIT /B 32767
)
:distSysUtilsUpdated
(
START "Cleaning up SysUtils and reinstalling PreInstalled" /MIN /WAIT %comspec% /C "D:\Distributives\Soft\PreInstalled\SysUtils-cleanup and reinstall.cmd"
EXIT /B
)
