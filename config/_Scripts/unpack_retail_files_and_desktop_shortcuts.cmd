@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64bit=1"
IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64bit=1"

rem XP workaround
IF NOT DEFINED ProgramData (
    REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "ProgramData" /t REG_EXPAND_SZ /d "%%ALLUSERSPROFILE%%\Application Data" /f
    SET "ProgramData=%ALLUSERSPROFILE%\Application Data"
)

IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

CALL :FindCommonDesktopPath

rem Default user profile:
IF NOT DEFINED DefaultUserProfile CALL "%~dp0copyDefaultUserProfile.cmd"

IF NOT DEFINED exe7z CALL "%~dp0find7zexe.cmd" || EXIT /B

IF EXIST D:\1S\Rarus\ShopBTS SET "Inst1S=1"
)
IF DEFINED HKUDStartup %exe7z% x -aoa -o"%HKUDStartup%\" -- "%~dp0..\Users\depts\startup.7z"
IF DEFINED CommonDesktop (
    REM Unpacking Desktop Shortcuts / Распаковка ярлыков на рабочий стол 
    RD /S /Q "%CommonDesktop%\Дополнительные ярлыки"
    RD /S /Q "%CommonDesktop%\Сервисы сторонних компаний"

    %exe7z% x -aoa -o"%CommonDesktop%" -- "%~dp0..\Users\depts\Desktop_shortcuts.7z"
    IF "%OS64bit%"=="1" %exe7z% x -aoa -o"%CommonDesktop%" -- "%~dp0..\Users\depts\Desktop_shortcuts_64bit.7z"
    IF NOT EXIST D:\Distributives\config IF EXIST W:\Distributives\config %exe7z% x -aoa -o"%CommonDesktop%" -- "%~dp0..\Users\depts\Desktop_shortcuts_W.7z"
    
    FOR %%I IN ("%~dp0..\Users\depts\?.7z") DO %exe7z% x -aoa -o"%%~nI:\" -- "%%~I"
    
    IF "%Inst1S%"=="1" (
	%exe7z% x -aoa -o"%CommonDesktop%" -- "%~dp0..\Users\depts\Desktop_shortcuts_1S.7z"
	IF "%OS64bit%"=="1" %exe7z% x -aoa -o"%CommonDesktop%" -- "%~dp0..\Users\depts\Desktop_shortcuts_1S_64bit.7z"
	%exe7z% x -aoa -o"%ProgramData%\mobilmir.ru" -- "\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\Rarus_Scripts.7z"
    )

ECHO N|%SystemRoot%\System32\net.exe SHARE "Обмен" /Delete
%SystemRoot%\System32\net.exe SHARE "Обмен=d:\Users\Public" /GRANT:"Everyone,CHANGE"
%SystemRoot%\System32\net.exe SHARE "Обмен=d:\Users\Public" /GRANT:"Все,CHANGE"
%SystemRoot%\System32\net.exe SHARE "Обмен=d:\Users\Public"

CALL "%~dp0Tasks\All XML.cmd"

ENDLOCAL
EXIT /B
)

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
