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
    IF NOT DEFINED exe7z CALL "%~dp0find7zexe.cmd" || EXIT /B

    CALL :FindCommonDesktopPath
    IF NOT DEFINED DefaultUserProfile CALL "%~dp0copyDefaultUserProfile.cmd"
    IF EXIST D:\1S\Rarus\ShopBTS SET "Inst1S=1"
)
(
    FOR %%I IN ("%~dp0..\Users\depts\?.7z") DO %exe7z% x -aoa -o"%%~nI:\" -- "%%~I"
    FOR /D %%I IN ("%~dp0..\Users\depts\?") DO IF EXIST "%%~nI:\*.*" XCOPY "%%~I\*.*" "%%~nI:\" /E /I /Q /G /H /R /K /O /Y /B /J

    ECHO N|%SystemRoot%\System32\net.exe SHARE "�����" /Delete
    %SystemRoot%\System32\net.exe SHARE "�����=d:\Users\Public" /GRANT:"Everyone,CHANGE"
    %SystemRoot%\System32\net.exe SHARE "�����=d:\Users\Public" /GRANT:"��,CHANGE"
    %SystemRoot%\System32\net.exe SHARE "�����=d:\Users\Public"

    IF DEFINED HKUDStartup %exe7z% x -aoa -o"%HKUDStartup%\" -- "%~dp0..\Users\depts\startup.7z"
    IF DEFINED CommonDesktop (
	ECHO.|DEL /F "%CommonDesktop%\Exchange.lnk"
	ECHO.|DEL /F "%CommonDesktop%\������� �� ���㧮� �����.lnk"
	RD /S /Q "%CommonDesktop%\�������⥫�� ��모"
	RD /S /Q "%CommonDesktop%\��ࢨ�� ��஭��� ��������"

	REM ��ᯠ����� ��몮� �� ࠡ�稩 �⮫ 
	%exe7z% x -aoa -o"%CommonDesktop%" -- "%~dp0..\Users\depts\Desktop_shortcuts.7z"
	IF "%OS64bit%"=="1" %exe7z% x -aoa -o"%CommonDesktop%" -- "%~dp0..\Users\depts\Desktop_shortcuts_64bit.7z"
	
	IF "%Inst1S%"=="1" (
	    %exe7z% x -aoa -o"%CommonDesktop%" -- "%~dp0..\Users\depts\Desktop_shortcuts_1S.7z"
	    IF "%OS64bit%"=="1" %exe7z% x -aoa -o"%CommonDesktop%" -- "%~dp0..\Users\depts\Desktop_shortcuts_1S_64bit.7z"
	    %exe7z% x -aoa -o"%ProgramData%\mobilmir.ru" -- "\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\Rarus_Scripts.7z"
	)
    )

    IF NOT DEFINED AutohotkeyExe CALL "%~dp0FindAutoHotkeyExe.cmd"
    IF DEFINED AutohotkeyExe (
	FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
	CALL "%ProgramData%\mobilmir.ru\_get_SharedMailUserId.cmd"
	FOR %%A IN ("D:\Local_Scripts\RetailHelper.ahk") DO SET "RetailHelperAhkTime=%%~tA"
	FOR %%A IN ("D:\dealer.beeline.ru\bin\criacx.cab") DO SET "criacxcabTime=%%~tA"
	CALL :PostForm
    )
    CALL "%~dp0ScriptUpdater_dist\InstallScriptUpdater.cmd" "D:\Local_Scripts\ScriptUpdater" && START "UpdateShortcuts.cmd" /MIN %comspec% /C "d:\Local_Scripts\UpdateShortcuts.cmd"
    EXIT /B
)
:PostForm
FOR /F "usebackq delims=" %%A IN ("%~dp0pseudo-secrets\%~nx0.txt") DO (
    START "" %AutohotkeyExe% "%~dp0Lib\PostGoogleForm.ahk" "%%~A" "entry.1278320779=%MailUserId%" "entry.1958374743=%Hostname%" "entry.2091378917=%RetailHelperAhkTime%" "entry.1721351309=%criacxcabTime%"
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
	@ECHO �� 㤠���� ��।����� ���� � ��饬� ࠡ�祬� �⮫�. ��모 �ᯠ������ �� ����!
	EXIT /B 1
    )
)
(
    FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO "%CommonDesktop%"`) DO SET "CommonDesktop=%%~I"
EXIT /B
)
:ReqQueryParamsXP
(
    REM � 2000 � XP REG.EXE �뤠�� १���� � ࠧ����⥫�� \t
    SET RegQueryParsingOptions="usebackq tokens=2* delims=	"
    IF NOT DEFINED recodeexe CALL "%~dp0find_exe.cmd" recodeexe recode.exe %SystemDrive%\SysUtils\UnxUtils\recode.exe
    IF DEFINED recodeexe SET "recodecmd=^^^|%recodeexe% -f --sequence=memory 1251..866"
EXIT /B
)
