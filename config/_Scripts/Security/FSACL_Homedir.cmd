@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    IF NOT DEFINED AutohotkeyExe CALL "%~dp0..\FindAutoHotkeyExe.cmd"
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
    
    SET "now=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%_%TIME::=%"
    SET "tgt=%~f1"
)
    IF "%tgt:~-1%"=="\" SET "tgt=%tgt:~0,-1%"
(
    ECHO Настройка параметров безопасности для "%tgt%"
    PUSHD "%tgt%"||EXIT /B 1
    SET "DirUserName="
    IF DEFINED AutohotkeyExe FOR /F "usebackq delims=" %%U IN (`^"%AutohotkeyExe% "%~dp0HomedirToSID.ahk" "%tgt%"^"`) DO IF NOT ERRORLEVEL 1 SET "DirUserName=%%U;s:y"
    IF NOT DEFINED DirUserName (
	REM old way: If user with dirname not exist, ignore the directory
	NET USER "%~nx1" >NUL 2>&1 || EXIT /B 1
	SET "DirUserName=%~nx1;s:n"
    )
    IF NOT EXIST "%tgt%\AppData\Local\ACL-backup" (
	MKDIR "%tgt%\AppData\Local\ACL-backup"
	COMPACT /C "%tgt%\AppData\Local\ACL-backup"
    )
    SET "bkpPackages=%tgt%\AppData\Local\ACL-backup\AppDataLocalPackages"
    SET "bkpPublishers=%tgt%\AppData\Local\ACL-backup\AppDataLocalPublishers"
    SET "bkpCertificates=%tgt%\AppData\Local\ACL-backup\AppDataRoamingMSSystemCertificates"
)
(
    ECHO %DATE% %TIME% Сохранение резервных копий ACL для "%tgt%"
    %SetACLexe% -on "%tgt%" -ot file -actn list -lst "f:sddl;w:d,o,g" -bckp "%tgt%\AppData\Local\ACL-backup\fullprofile.%now%.sddl" -silent
    
    CALL :backupACLFlagSubdir "%tgt%\AppData\Local\Packages" "%bkpPackages%" || EXIT /B
    CALL :backupACLFlagSubdir "%tgt%\AppData\Local\Publishers" "%bkpPublishers%" || EXIT /B
    CALL :backupACLFlagSubdir "%tgt%\AppData\Roaming\Microsoft\SystemCertificates" "%bkpCertificates%" || EXIT /B
    
    REM take ownership just in case; will be handled back after permissions setup
    ECHO %DATE% %TIME% Сброс владельца для "%tgt%"
    CALL "%~dp0TAKEOWN_SKIPSL.cmd" /F "%tgt%" /A /R /D Y >NUL
    rem CALL "%~dp0..\CheckWinVer.cmd" 6.2 && %SystemRoot%\System32\TAKEOWN.exe /F "%tgt%" /A /R /D Y /SKIPSL >NUL
    rem IF ERRORLEVEL 1 %SystemRoot%\System32\TAKEOWN.exe /F "%tgt%" /A /R /D Y >NUL
    REM -rec cont_obj -actn setowner -ownr "n:%UIDAdministrators%"
    ECHO %DATE% %TIME% Сброс ACL для "%tgt%"
    %SetACLexe% -on "%tgt%" -ot file -rec cont_obj -actn rstchldrn -rst dacl -silent
    REM Allow users modify, do not allow execute
    ECHO %DATE% %TIME% Разрешение пользователю менять "%tgt%", запретить запускать программы
    %SetACLexe% -on "%tgt%" -ot file -actn setprot -op "dacl:p_nc;sacl:np" -actn clear -clr dacl -actn ace -ace "n:%UIDAdministrators%;p:full;i:sc,so" -actn ace -ace "n:%UIDSYSTEM%;p:full;i:sc,so" -actn ace -ace "n:%DirUserName%;p:change,FILE_DELETE_CHILD;i:sc" -actn ace -ace "n:%DirUserName%;p:write,read,FILE_DELETE_CHILD,DELETE;i:io,so" -silent
    ECHO %DATE% %TIME% Смена владельца "%tgt%" на %DirUserName%
    %SetACLexe% -on "%tgt%" -ot file -rec cont_obj -actn setowner -ownr "n:%DirUserName%" -silent
    rem %SetACLexe% -on "%tgt%\AppData\Local\Temp" -ot file -actn clear -clr dacl -actn rstchldrn -rst dacl -actn ace -ace "n:%UIDAdministrators%;p:full;i:sc,so" -actn ace -ace "n:%UIDSYSTEM%;p:full;i:sc,so" -actn ace -ace "n:%DirUserName%;p:change,FILE_DELETE_CHILD;i:sc" -actn ace -ace "n:%DirUserName%;p:write,read,FILE_DELETE_CHILD,DELETE;i:io,so"
    
    rem defaults: %user%	1	DACL(protected):СИСТЕМА,full,allow,container_inherit+object_inherit:Администраторы,full,allow,container_inherit+object_inherit:%user%,full,allow,container_inherit+object_inherit;Owner:СИСТЕМА;Group:СИСТЕМА
    
    ECHO %DATE% %TIME% Установка владельца и специальных ACL для некоторых папок, как в профиле по умолчанию
    %SetACLexe% -on "%tgt%" -ot file -actn setowner -ownr "n:%UIDSYSTEM%" -actn setgroup -grp "n:%UIDSYSTEM%" -silent
    %SetACLexe% -on "%tgt%\AppData\Local\Microsoft\Windows\UPPS" -ot file -rec cont_obj -actn setowner -ownr "n:%UIDSYSTEM%" -actn setgroup -grp "n:%UIDSYSTEM%" -silent
    rem %SetACLexe% -on "%tgt%\AppData\Local\Microsoft\Windows\UPPS\UPPS.bin" -ot file -actn setowner -ownr "n:%UIDSYSTEM%" -actn setgroup -grp "n:%UIDSYSTEM%" -silent
    %SetACLexe% -on "%tgt%\AppData\Local\TileDataLayer\Database\EDBtmp.log" -ot file -rec cont_obj -actn setowner -ownr "n:%UIDSYSTEM%" -actn setgroup -grp "n:%UIDSYSTEM%" -silent
    %SetACLexe% -on "%tgt%\AppData\LocalLow" -ot file -rec cont_obj -actn setowner -ownr "n:%UIDSYSTEM%" -actn setgroup -grp "n:%UIDSYSTEM%" -silent
    
    FOR %%A IN ("%tgt%\AppData\Local\Microsoft\Windows\UsrClass.dat*" "%tgt%\ntuser.dat*" "%tgt%\ntuser.ini") DO %SetACLexe% -on %%A -ot file -actn setowner -ownr "n:%UIDSYSTEM%" -actn setgroup -grp "n:%UIDSYSTEM%" -silent
    
    rem left non-restored:
    rem AppData\Local\Microsoft\Windows\Caches\cversions.3.db	1	DACL(not_protected):ЦЕНТР ПАКЕТОВ ПРИЛОЖЕНИЙ\ВСЕ ПАКЕТЫ ПРИЛОЖЕНИЙ,read,allow,no_inheritance;
    rem AppData\Local\Microsoft\Windows\Caches\{38117EE8-B905-4D30-88C9-B63C603DA134}.3.ver0x0000000000000001.db	1	DACL(not_protected):ЦЕНТР ПАКЕТОВ ПРИЛОЖЕНИЙ\ВСЕ ПАКЕТЫ ПРИЛОЖЕНИЙ,read,allow,no_inheritance;
    rem AppData\Local\Microsoft\Windows\Caches\{3DA71D5A-20CC-432F-A115-DFE92379E91F}.3.ver0x0000000000000006.db	1	DACL(not_protected):ЦЕНТР ПАКЕТОВ ПРИЛОЖЕНИЙ\ВСЕ ПАКЕТЫ ПРИЛОЖЕНИЙ,read,allow,no_inheritance;
    rem AppData\Local\Microsoft\Windows\INetCache\counters.dat	1	DACL(not_protected):ЦЕНТР ПАКЕТОВ ПРИЛОЖЕНИЙ\ВСЕ ПАКЕТЫ ПРИЛОЖЕНИЙ,read_execute,allow,no_inheritance;
    
    ECHO %DATE% %TIME% Разрешение изменения и выполнения файлов из некоторых папок
    CALL "%srcpath%FSACL_Change.cmd" "%DirUserName%" "%tgt%\Mail\Thunderbird\profile\extensions" "%tgt%\AppData\Local\Google\Chrome\User Data\PepperFlash" "%tgt%\AppData\Local\Google\Chrome\User Data\WidevineCDM" "%tgt%\AppData\Local\Google\Chrome\User Data\SwiftShader" "%tgt%\AppData\Local\Programs"
    
    ECHO %DATE% %TIME% Запрет просмотра списка файлов для некоторых папок
    REM DACL(not_protected+auto_inherited):Все,FILE_LIST_DIRECTORY,deny,no_inheritance;Owner:СИСТЕМА;Group:СИСТЕМА
    CALL :DenyListDirectory "%UIDEveryone%" "%tgt%\AppData\Local\Application Data" "%tgt%\AppData\Local\History" "%tgt%\AppData\Local\Microsoft\Windows\INetCache\Content.IE5" "%tgt%\AppData\Local\Microsoft\Windows\Temporary Internet Files" "%tgt%\AppData\Local\Temporary Internet Files" "%tgt%\AppData\Roaming\Microsoft\Windows\Start Menu\Программы" "%tgt%\Application Data" "%tgt%\Cookies" "%tgt%\Documents\Мои видеозаписи" "%tgt%\Documents\мои рисунки" "%tgt%\Documents\Моя музыка" "%tgt%\Local Settings" "%tgt%\NetHood" "%tgt%\PrintHood" "%tgt%\Recent" "%tgt%\SendTo" "%tgt%\главное меню" "%tgt%\Мои документы" "%tgt%\Шаблоны"
    
    CALL :restoreACLUnflagSubdir "%tgt%\AppData\Local\Packages" "%bkpPackages%"
    CALL :restoreACLUnflagSubdir "%tgt%\AppData\Local\Publishers" "%bkpPublishers%"
    CALL :restoreACLUnflagSubdir "%tgt%\AppData\Roaming\Microsoft\SystemCertificates" "%bkpCertificates%"
    
    rem without FULL access to TEMP, HP MF driver hangs when printing non-PDFs :(
    FOR /F "usebackq delims=" %%Z IN ("%~dp0Allow TEMP full access.txt") DO IF /I "%COMPUTERNAME%"=="%%Z" %SetACLexe% -on "%tgt%\AppData\Local\Temp" -ot file -rec cont_obj -actn setowner -ownr "n:%DirUserName%" -actn rstchldrn -rst dacl -actn ace -ace "n:%DirUserName%;p:full"
    POPD
EXIT /B
)

:backupACLFlagSubdir <path> <backup-name>
(
    IF NOT EXIST %1 EXIT /B 0
    IF EXIST "%~2.flag" CALL :AskRestoreACL %* || EXIT /B
    ECHO %DATE% %TIME% Сохранение резервной копии ACL для %1
    (ECHO Not restored)>"%~2.flag"
    %SetACLexe% -on %1 -ot file -rec cont_obj -actn list -lst "f:sddl;w:d,o,g" -bckp "%~2.%now%.sddl" -silent
    COMPACT /C /F /EXE:LZX "%~2.%now%.sddl" >NUL 2>&1
EXIT /B
)
:AskRestoreACL <path> <backup-name>
(
    IF "%RunInteractiveInstalls%"=="0" EXIT /B 1
    SETLOCAL ENABLEEXTENSIONS
    rem ENABLEDELAYEDEXPANSION
    FOR %%A IN ("%~2.flag") DO ECHO Обнаружен старый ^(%%~tA^) флаг, обозначающий наличие сохранённых но не восстановленных ACL.
    ECHO.
    ECHO Имеющиеся резервные копии:
    DIR /B "%~2.*.sddl"
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
	SET "restoreMask=%~2.*.sddl"
    ) ELSE IF EXIST "%~dp2%usrInp%" (
	SET "restoreMask=%~dp2%usrInp%"
    ) ELSE IF EXIST "%~dp2%usrInp%.sddl" (
	SET "restoreMask=%~dp2%usrInp%.sddl"
    )
    CALL :InitRemembering
)
(
    FOR %%A IN ("%restoreMask%") DO CALL :RememberIfLatest restoreFile "%%A"
    IF NOT DEFINED restoreFile EXIT /B 1
)
    ECHO %DATE% %TIME% Восстановление сохранённых ACL для %1
    %SetACLexe% -on %1 -ot file -actn restore -bckp "%restoreFile%" -silent && DEL "%~2.flag"
    EXIT /B
:restoreACLUnflagSubdir <path> <backup-name>
(
    ECHO %DATE% %TIME% Восстановление сохранённых ACL для %1
    %SetACLexe% -on %1 -ot file -actn restore -bckp "%~2.%now%.sddl" -silent && DEL "%~2.flag"
EXIT /B
)
:DenyListDirectory <user> <path> <path> <...>
(
    IF "%~2"=="" EXIT /B
    REM DACL(not_protected+auto_inherited):Все,FILE_LIST_DIRECTORY,deny,no_inheritance;Owner:СИСТЕМА;Group:СИСТЕМА
    %SetACLexe% -on "%2" -ot file -actn setprot -op "dacl:np" -actn ace -ace "n:%UIDEveryone%;p:FILE_LIST_DIRECTORY;i:np;m:deny" -actn setowner -ownr "n:%DirUserName%" -silent
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
