@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64bit=1"
IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64bit=1"

    IF NOT DEFINED exe7z CALL "%~dp0find7zexe.cmd" || EXIT /B

    CALL :FindCommonDesktopPath
    IF NOT DEFINED DefaultUserProfile CALL "%~dp0copyDefaultUserProfile.cmd"
    IF EXIST D:\1S SET "unpackShortcuts1S=1"
)
(
    FOR %%I IN ("%~dp0..\Users\depts\?.7z") DO %exe7z% x -aoa -o"%%~nI:\" -- "%%~I"
    FOR /D %%I IN ("%~dp0..\Users\depts\?") DO IF EXIST "%%~nI:\*.*" XCOPY "%%~I\*.*" "%%~nI:\" /E /I /Q /G /H /R /K /O /Y /B /J

    ECHO N|%SystemRoot%\System32\net.exe SHARE "Обмен" /Delete
    %SystemRoot%\System32\net.exe SHARE "Обмен=d:\Users\Public" /GRANT:"Everyone,CHANGE"
    %SystemRoot%\System32\net.exe SHARE "Обмен=d:\Users\Public" /GRANT:"Все,CHANGE"
    %SystemRoot%\System32\net.exe SHARE "Обмен=d:\Users\Public"

    IF DEFINED HKUDStartup %exe7z% x -aoa -o"%HKUDStartup%\" -- "%~dp0..\Users\depts\startup.7z"
    IF DEFINED CommonDesktop (
	ECHO.|DEL /F "%CommonDesktop%\Exchange.lnk"
	ECHO.|DEL /F "%CommonDesktop%\Ценники из выгрузок Рарус.lnk"
	ECHO.|DEL /F "%CommonDesktop%\1С*.lnk"
        rem ECHO.|DEL /F "%CommonDesktop%\1С 8 Розница Продавец.lnk"
        rem ECHO.|DEL /F "%CommonDesktop%\1С.lnk"
        rem ECHO.|DEL /F "%CommonDesktop%\1С - Рарус - Продавец.lnk"
	RD /S /Q "%CommonDesktop%\Дополнительные ярлыки"
	RD /S /Q "%CommonDesktop%\Сервисы сторонних компаний"

	REM Распаковка ярлыков на рабочий стол 
	%exe7z% x -aoa -o"%CommonDesktop%" -- "%~dp0..\Users\depts\Desktop_shortcuts.7z"
	IF "%OS64bit%"=="1" %exe7z% x -aoa -o"%CommonDesktop%" -- "%~dp0..\Users\depts\Desktop_shortcuts_64bit.7z"
	
	IF "%unpackShortcuts1S%"=="1" (
	    %exe7z% x -aoa -o"%CommonDesktop%" -- "%~dp0..\Users\depts\Desktop_shortcuts_1S.7z"
	    IF "%OS64bit%"=="1" %exe7z% x -aoa -o"%CommonDesktop%" -- "%~dp0..\Users\depts\Desktop_shortcuts_1S_64bit.7z"
	    %exe7z% x -aoa -o"%ProgramData%\mobilmir.ru" -- "\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\Rarus_Scripts.7z"
	)
    )

    CALL "%~dp0FindAutoHotkeyExe.cmd"
    IF DEFINED AutohotkeyExe (
	FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
	CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
	FOR %%A IN ("D:\Local_Scripts\RetailHelper.ahk") DO SET "RetailHelperAhkTime=%%~tA"
	CALL :PostForm
    )
    CALL "%~dp0ScriptUpdater_dist\InstallScriptUpdater.cmd" "D:\Local_Scripts\ScriptUpdater" && START "UpdateShortcuts.cmd" /MIN %comspec% /C "d:\Local_Scripts\UpdateShortcuts.cmd"
    EXIT /B
)
:PostForm
FOR /F "usebackq delims=" %%A IN ("%~dp0pseudo-secrets\%~nx0.txt") DO (
    START "" %AutohotkeyExe% "%~dp0Lib\PostGoogleForm.ahk" "%%~A" "entry.1278320779=%MailUserId%" "entry.1958374743=%Hostname%" "entry.2091378917=%RetailHelperAhkTime%"
EXIT /B
)
EXIT /B
:FindCommonDesktopPath
(
    SET RegQueryParsingOptions="usebackq tokens=3* delims= "
    CALL "%~dp0CheckWinVer.cmd" 6 || CALL :ReqQueryParamsXP
)
(
    FOR /F %RegQueryParsingOptions% %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Common Desktop" %recodecmd%`) DO SET "CommonDesktop=%%~J"
    IF NOT DEFINED CommonDesktop (
	@ECHO Не удалось определить путь к общему рабочему столу. Ярлыки распакованы не будут!
	EXIT /B 1
    )
)
(
    FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO "%CommonDesktop%"`) DO SET "CommonDesktop=%%~I"
EXIT /B
)
:ReqQueryParamsXP
(
    REM в 2000 и XP REG.EXE выдаёт результат с разделителем \t
    SET RegQueryParsingOptions="usebackq tokens=2* delims=	"
    IF NOT DEFINED recodeexe CALL "%~dp0find_exe.cmd" recodeexe recode.exe %SystemDrive%\SysUtils\UnxUtils\recode.exe
    IF DEFINED recodeexe SET "recodecmd=^^^|%recodeexe% -f --sequence=memory 1251..866"
EXIT /B
)
