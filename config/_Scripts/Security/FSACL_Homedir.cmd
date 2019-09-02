@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    CALL "%~dp0..\FindAutoHotkeyExe.cmd"
    IF NOT DEFINED SetACLexe CALL "%~dp0..\find_exe.cmd" SetACLexe SetACL.exe "%SystemDrive%\SysUtils\SetACL.exe"
    IF NOT DEFINED SetACLexe (
	ECHO SetACL.exe не найден, продолжение невозможно.
	EXIT /B 2
    )

    SET "saUIDEveryone=S-1-1-0;s:y"
    SET "saUIDAuthenticatedUsers=S-1-5-11;s:y"
    SET "saUIDUsers=S-1-5-32-545;s:y"
    SET "saUIDSYSTEM=S-1-5-18;s:y"
    SET "saUIDCreatorOwner=S-1-3-0;s:y"
    SET "saUIDAdministrators=S-1-5-32-544;s:y"
    
    SET "tgt=%~f1"
    SET "TimeS=%TIME:~0,-3%"
)
(
    SET "now=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%_%TimeS::=%"
    IF "%tgt:~-1%"=="\" SET "tgt=%tgt:~0,-1%"
)
SET "ACLBackupDir=%tgt%\AppData\Local\ACL-backup"
(
    IF NOT EXIST "%ACLBackupDir%" (
	MKDIR "%ACLBackupDir%"
	%SystemRoot%\System32\COMPACT.exe /C "%ACLBackupDir%"
    )

    ECHO Настройка параметров безопасности для "%tgt%"
    PUSHD "%tgt%"||EXIT /B 1
    SET "saUIDProfileOwner="
    IF DEFINED AutohotkeyExe FOR /F "usebackq delims=" %%U IN (`^"%AutohotkeyExe% "%~dp0HomedirToSID.ahk" "%tgt%"^"`) DO IF NOT ERRORLEVEL 1 (
        SET "iUIDProfileOwner=*%%~U"
        SET "saUIDProfileOwner=%%~U;s:y"
    )
    IF NOT DEFINED saUIDProfileOwner (
	REM old way: If user with dirname not exist, ignore the directory
	NET USER "%~nx1" >NUL 2>&1 || EXIT /B 1
        SET "iUIDProfileOwner=%~nx1"
	SET "saUIDProfileOwner=%~nx1;s:n"
    )
)
(
    CALL :backupACL "%tgt%" fullprofile || EXIT /B
    
    CALL :backupACLFlagSubdir "%tgt%\AppData\Local\Packages" "AppDataLocalPackages" || EXIT /B
    CALL :backupACLFlagSubdir "%tgt%\AppData\Local\Publishers" "AppDataLocalPublishers" || EXIT /B
    CALL :backupACLFlagSubdir "%tgt%\AppData\Roaming\Microsoft\SystemCertificates" "AppDataRoamingMSSystemCertificates" || EXIT /B
    CALL :backupACLFlagSubdir "%tgt%\AppData\Local\Microsoft\Windows\Caches" "AppDataLocalMicrosoftWindowsCaches" || EXIT /B
    CALL :backupACLFlagSubdir "%tgt%\AppData\Roaming\Microsoft\Windows\CloudStore" "AppDataRoamingMicrosoftWindowsCloudStore" || EXIT /B
    
    REM take ownership just in case; will be handled back after permissions setup
    CALL :LogWithDate Сброс владельца для "%tgt%"
    CALL "%~dp0TAKEOWN_SKIPSL.cmd" /F "%tgt%" /A >NUL
    rem CALL "%~dp0..\CheckWinVer.cmd" 6.2 && %SystemRoot%\System32\TAKEOWN.exe /F "%tgt%" /A /R /D Y /SKIPSL >NUL
    rem IF ERRORLEVEL 1 %SystemRoot%\System32\TAKEOWN.exe /F "%tgt%" /A /R /D Y >NUL
    REM -rec cont_obj -actn setowner -ownr "n:%saUIDAdministrators%"
    CALL :LogWithDate Сброс ACL для "%tgt%"
    %SetACLexe% -on "%tgt%" -ot file -rec cont_obj -actn rstchldrn -rst dacl -ignoreerr -silent
    REM Allow users modify, do not allow execute
    CALL :LogWithDate Разрешение пользователю менять "%tgt%", запретить запускать программы
    %SetACLexe% -on "%tgt%" -ot file -actn setprot -op "dacl:p_nc;sacl:np" -actn clear -clr dacl -actn ace -ace "n:%saUIDAdministrators%;p:full;i:sc,so" -actn ace -ace "n:%saUIDSYSTEM%;p:full;i:sc,so" -actn ace -ace "n:%saUIDProfileOwner%;p:change,FILE_DELETE_CHILD;i:sc" -actn ace -ace "n:%saUIDProfileOwner%;p:write,read,FILE_DELETE_CHILD,DELETE;i:io,so" -ignoreerr -silent
    CALL :LogWithDate Смена владельца "%tgt%" на %saUIDProfileOwner%
    %SetACLexe% -on "%tgt%" -ot file -rec cont_obj -actn setowner -ownr "n:%saUIDProfileOwner%" -ignoreerr -silent
    rem %SetACLexe% -on "%tgt%\AppData\Local\Temp" -ot file -actn clear -clr dacl -actn rstchldrn -rst dacl -actn ace -ace "n:%saUIDAdministrators%;p:full;i:sc,so" -actn ace -ace "n:%saUIDSYSTEM%;p:full;i:sc,so" -actn ace -ace "n:%saUIDProfileOwner%;p:change,FILE_DELETE_CHILD;i:sc" -actn ace -ace "n:%saUIDProfileOwner%;p:write,read,FILE_DELETE_CHILD,DELETE;i:io,so"
    
    rem defaults: %user%	1	DACL(protected):СИСТЕМА,full,allow,container_inherit+object_inherit:Администраторы,full,allow,container_inherit+object_inherit:%user%,full,allow,container_inherit+object_inherit;Owner:СИСТЕМА;Group:СИСТЕМА
    
    CALL :LogWithDate Установка владельца и специальных ACL для некоторых папок, как в профиле по умолчанию
    CALL :SetSystemOwnerAndGroup "%tgt%" "%tgt%\AppData\Local\Microsoft\Windows\UPPS\UPPS.bin" "%tgt%\AppData\Local\TileDataLayer\Database\EDBtmp.log" "%tgt%\Application Data" "%tgt%\AppData\Local\Temporary Internet Files" "%tgt%\AppData\Local\Microsoft\Windows\Temporary Internet Files" "%tgt%\AppData\Local\Application Data" "%tgt%\AppData\Local\History"
     
    
    %SystemRoot%\System32\icacls.exe "%tgt%\AppData\Local\Microsoft\WindowsApps" /grant "%iUIDProfileOwner%:(IO)(OI)(CI)RX" /C /L
    CALL :SetSystemOwnerAndGroupRec "%tgt%\AppData\Local\Microsoft\Windows\UPPS" "%tgt%\AppData\LocalLow" "%tgt%\AppData\Local\Microsoft\WindowsApps"
    rem AppData\Local\Microsoft\WindowsApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe	1	Owner:NT AUTHORITY\СИСТЕМА;Group:NT AUTHORITY\СИСТЕМА
    rem AppData\Local\Microsoft\WindowsApps\MicrosoftEdge.exe	1	Owner:NT AUTHORITY\СИСТЕМА;Group:NT AUTHORITY\СИСТЕМА
    
    CALL :SetSystemOwnerAndGroupForFiles "%tgt%\AppData\Local\Microsoft\Windows\UsrClass.dat*" "%tgt%\ntuser.dat*" "%tgt%\ntuser.ini" "%tgt%\AppData\Local\Microsoft\Windows\UPPS\UPPS.bin" "%tgt%\AppData\Local\TileDataLayer\Database\EDBtmp.log"
    CALL "%~dp0..\CheckWinVer.cmd" 6 && (
        CALL :LogWithDate Запрет просмотра списка файлов для некоторых папок
        REM DACL(not_protected+auto_inherited):Все,FILE_LIST_DIRECTORY,deny,no_inheritance;Owner:СИСТЕМА;Group:СИСТЕМА
        CALL :DenyListDirectory "%saUIDEveryone%" "%tgt%\AppData\Local\Application Data" "%tgt%\AppData\Local\History" "%tgt%\AppData\Local\Microsoft\Windows\INetCache\Content.IE5" "%tgt%\AppData\Local\Microsoft\Windows\Temporary Internet Files" "%tgt%\AppData\Local\Temporary Internet Files" "%tgt%\AppData\Roaming\Microsoft\Windows\Start Menu\Программы" "%tgt%\Application Data" "%tgt%\Cookies" "%tgt%\Documents\Мои видеозаписи" "%tgt%\Documents\мои рисунки" "%tgt%\Documents\Моя музыка" "%tgt%\Local Settings" "%tgt%\NetHood" "%tgt%\PrintHood" "%tgt%\Recent" "%tgt%\SendTo" "%tgt%\главное меню" "%tgt%\Мои документы" "%tgt%\Шаблоны"
    )
    
    rem left non-restored:
    rem AppData\Local\Microsoft\Windows\Caches\cversions.3.db	1	DACL(not_protected):ЦЕНТР ПАКЕТОВ ПРИЛОЖЕНИЙ\ВСЕ ПАКЕТЫ ПРИЛОЖЕНИЙ,read,allow,no_inheritance;
    rem AppData\Local\Microsoft\Windows\Caches\{38117EE8-B905-4D30-88C9-B63C603DA134}.3.ver0x0000000000000001.db	1	DACL(not_protected):ЦЕНТР ПАКЕТОВ ПРИЛОЖЕНИЙ\ВСЕ ПАКЕТЫ ПРИЛОЖЕНИЙ,read,allow,no_inheritance;
    rem AppData\Local\Microsoft\Windows\Caches\{3DA71D5A-20CC-432F-A115-DFE92379E91F}.3.ver0x0000000000000006.db	1	DACL(not_protected):ЦЕНТР ПАКЕТОВ ПРИЛОЖЕНИЙ\ВСЕ ПАКЕТЫ ПРИЛОЖЕНИЙ,read,allow,no_inheritance;
    rem AppData\Local\Microsoft\Windows\INetCache\counters.dat	1	DACL(not_protected):ЦЕНТР ПАКЕТОВ ПРИЛОЖЕНИЙ\ВСЕ ПАКЕТЫ ПРИЛОЖЕНИЙ,read_execute,allow,no_inheritance;
    rem AppData\Local\Microsoft\Windows\INetCache\counters2.dat	1	DACL(not_protected):ЦЕНТР ПАКЕТОВ ПРИЛОЖЕНИЙ\ВСЕ ПАКЕТЫ ПРИЛОЖЕНИЙ,read_execute,allow,no_inheritance:ЦЕНТР ПАКЕТОВ ПРИЛОЖЕНИЙ\Подключение к Интернету,read_execute,allow,no_inheritance:ЦЕНТР ПАКЕТОВ ПРИЛОЖЕНИЙ\Подключение к Интернету, включая входящие подключения из Интернета,read_execute,allow,no_inheritance:ЦЕНТР ПАКЕТОВ ПРИЛОЖЕНИЙ\Домашние или рабочие сети,read_execute,allow,no_inheritance

    CALL :LogWithDate Разрешение изменения и выполнения файлов из некоторых папок
    CALL "%srcpath%FSACL_Change.cmd" "%saUIDProfileOwner%" "%tgt%\AppData\Local\Google\Chrome\User Data\PepperFlash" "%tgt%\AppData\Local\Google\Chrome\User Data\WidevineCDM" "%tgt%\AppData\Local\Google\Chrome\User Data\SwiftShader" "%tgt%\AppData\Local\Programs" "%tgt%\AppData\Local\SkbKontur"
    REM "%tgt%\Mail\Thunderbird\profile\extensions"
    CALL :LogWithDate Исправление последствий опечатки --- \ в конце предыдущей команды
    %SetACLexe% -on \ -ot file -actn ace -ace "n:%saUIDProfileOwner%;p:change;i:so,sc;m:revoke;w:dacl" -ignoreerr -silent
    
    CALL :restoreACLUnflagSubdir "%tgt%\AppData\Local\Packages" "AppDataLocalPackages"
    CALL :restoreACLUnflagSubdir "%tgt%\AppData\Local\Publishers" "AppDataLocalPublishers"
    CALL :restoreACLUnflagSubdir "%tgt%\AppData\Roaming\Microsoft\SystemCertificates" "AppDataRoamingMSSystemCertificates"
    CALL :restoreACLUnflagSubdir "%tgt%\AppData\Local\Microsoft\Windows\Caches" "AppDataLocalMicrosoftWindowsCaches"
    CALL :restoreACLUnflagSubdir "%tgt%\AppData\Roaming\Microsoft\Windows\CloudStore" "AppDataRoamingMicrosoftWindowsCloudStore"
    
    rem without FULL access to TEMP, HP MF driver hangs when printing non-PDFs :(
    FOR /F "usebackq delims=" %%Z IN ("%~dp0Allow TEMP full access.txt") DO IF /I "%COMPUTERNAME%"=="%%Z" %SetACLexe% -on "%tgt%\AppData\Local\Temp" -ot file -rec cont_obj -actn setowner -ownr "n:%saUIDProfileOwner%" -actn rstchldrn -rst dacl -actn ace -ace "n:%saUIDProfileOwner%;p:full" -ignoreerr -silent
    POPD
EXIT /B
)
:LogWithDate
(
    ECHO %DATE% %TIME% %*
EXIT /B
)
:SetSystemOwnerAndGroup
(
    %SetACLexe% -on %1 -ot file -actn setowner -ownr "n:%saUIDSYSTEM%" -actn setgroup -grp "n:%saUIDSYSTEM%" -ignoreerr -silent
    SET "nextArgLabel=SetSystemOwnerAndGroup"
GOTO :CheckArgShift
)
:SetSystemOwnerAndGroupRec
(
    %SetACLexe% -on %1 -ot file -rec cont_obj -actn setowner -ownr "n:%saUIDSYSTEM%" -actn setgroup -grp "n:%saUIDSYSTEM%" -ignoreerr -silent
    SET "nextArgLabel=SetSystemOwnerAndGroupRec"
GOTO :CheckArgShift
)
:SetSystemOwnerAndGroupForFiles <paths>
(
    FOR /F "usebackq delims=" %%A IN (`DIR /B /A-D %1`) DO %SetACLexe% -on "%~dp1%%A" -ot file -actn setowner -ownr "n:%saUIDSYSTEM%" -actn setgroup -grp "n:%saUIDSYSTEM%" -ignoreerr -silent
    SET "nextArgLabel=SetSystemOwnerAndGroupForFiles"
GOTO :CheckArgShift
)
:CheckArgShift
(
    IF NOT "%~2"=="" ( SHIFT & GOTO :%nextArgLabel% )
    SET nextArgLabel=
    EXIT /B
)
    
:backupACLFlagSubdir <path> <backup-name>
(
    IF NOT EXIST %1 EXIT /B 0
    IF EXIST "%~2.flag" CALL :AskRestoreACL %* || EXIT /B
    (CALL :LogWithDate Запущено создание резервной копии от имени %USERNAME%)>>"%ACLBackupDir%\%~2.flag"
    CALL :backupACL %1 %2
    (CALL :LogWithDate Резервная копия сохранена, не восстановлена)>>"%ACLBackupDir%\%~2.flag"
EXIT /B
)
:backupACL <path> <backup-name>
(
    ECHO %DATE% %TIME% Сохранение резервной копии ACL для %1
    %SetACLexe% -on %1 -ot file -rec cont_obj -actn list -lst "f:sddl;w:d,o,g" -bckp "%ACLBackupDir%\%~2.%now%.sddl.tmp" -ignoreerr -silent||EXIT /B
    REN "%ACLBackupDir%\%~2.%now%.sddl.tmp" "*."||EXIT /B
    START "Compacting %~nx2.%now%.sddl" /MIN %SystemRoot%\System32\COMPACT.exe /C /F /EXE:LZX "%ACLBackupDir%\%~2.%now%.sddl" >NUL 2>&1
    EXIT /B 0
)
:AskRestoreACL <path> <backup-name>
(
    IF NOT DEFINED Unattended IF "%RunInteractiveInstalls%"=="0" SET "Unattended=1"
    IF DEFINED Unattended EXIT /B 1
    SETLOCAL ENABLEEXTENSIONS
    rem ENABLEDELAYEDEXPANSION
    FOR %%A IN ("%ACLBackupDir%\%~2.flag") DO (
	ECHO Обнаружен флаг, записанный ^(%%~tA^) обозначающий наличие сохранённых но не восстановленных ACL, с текстом:
	TYPE "%%~A"
    )
    ECHO.
    ECHO Имеющиеся резервные копии:
    DIR /B "%ACLBackupDir%\%~2.*.sddl"
    ECHO Введите имя файла резервной копии для восстановления или укажите:
    ECHO ^(пусто^)	- выход
    ECHO 0	- не восстанавливать
    ECHO *	- последняя резервная копия
    SET /P "usrInp=(имя файла, 0 или просто Enter) > "
    IF NOT DEFINED usrInp EXIT /B 1
)
(
    IF "%usrInp%"=="0" EXIT /B 0
    IF "%usrInp%"=="*" (
	SET "restoreMask=%ACLBackupDir%\%~2.*.sddl"
    ) ELSE IF EXIST "%ACLBackupDir%\%usrInp%" (
	SET "restoreMask=%ACLBackupDir%\%usrInp%"
    ) ELSE IF EXIST "%ACLBackupDir%\%usrInp%.sddl" (
	SET "restoreMask=%ACLBackupDir%\%usrInp%.sddl"
    ) ELSE (SET "restoreMask=%usrInp%")
    CALL :InitRemembering
)
(
    FOR %%A IN ("%restoreMask%") DO CALL :RememberIfLatest restoreFile "%%A"
    IF NOT DEFINED restoreFile EXIT /B 1
)
(
    ECHO %DATE% %TIME% Восстановление сохранённых ACL для %1
    %SetACLexe% -on %1 -ot file -actn restore -bckp "%restoreFile%" -ignoreerr -silent && DEL "%ACLBackupDir%\%~2.flag"
    EXIT /B
)
:restoreACLUnflagSubdir <path> <backup-name>
(
    ECHO %DATE% %TIME% Восстановление сохранённых ACL для %1
    %SetACLexe% -on %1 -ot file -actn restore -bckp "%ACLBackupDir%\%~2.%now%.sddl" -ignoreerr -silent && DEL "%ACLBackupDir%\%~2.flag"
EXIT /B
)
:DenyListDirectory <user> <path> <path> <...>
(
    IF "%~2"=="" EXIT /B
    REM DACL(not_protected+auto_inherited):Все,FILE_LIST_DIRECTORY,deny,no_inheritance;Owner:СИСТЕМА;Group:СИСТЕМА
    %SetACLexe% -on %2 -ot file -actn setprot -op "dacl:np" -actn ace -ace "n:%saUIDEveryone%;p:FILE_LIST_DIRECTORY;i:np;m:deny" -actn setowner -ownr "n:%saUIDAdministrators%" -actn setgroup -grp "n:%saUIDSYSTEM%" -ignoreerr -silent
    SHIFT /2
    GOTO :DenyListDirectory
EXIT /B
)
:InitRemembering
(
    SET "LatestDate=0000000000:00"
EXIT /B
)
:RememberIfLatest <varName> <path>
(
    SET "CurrentDate=%~t2"
)
(
@rem     01.12.2011 21:29, so reverse date to get correct comparison
    SET "CurrentDate=%CurrentDate:~6,4%%CurrentDate:~3,2%%CurrentDate:~0,2%%CurrentDate:~11%"
)
(
    IF "%CurrentDate%" GEQ "%LatestDate%" (
	SET "%~1=%~2"
	SET "LatestDate=%CurrentDate%"
    )
EXIT /B
)
