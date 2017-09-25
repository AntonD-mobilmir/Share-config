@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"

:Restart
    FOR /F "usebackq delims=" %%A IN ("%ProgramData%\mobilmir.ru\ScriptUpdaterDir.txt") DO SET "ScriptUpdaterDir=%%~A"
    
    rem Check if admin (XP and higher)
    %SystemRoot%\System32\fltmc.exe >nul 2>&1
    IF ERRORLEVEL 1 (
	rem Not admin, /RL LIMITED is in the task template
	SET "schtasksOptions=/IT"
	SET "abDir=%LOCALAPPDATA%\mobilmir.ru\AddressBook"
	SET "taskTemplate=AddressBook_download_LOCALAPPDATA.xml"
	IF NOT DEFINED ScriptUpdaterDir (
	    CALL "%~dp0..\ScriptUpdater_dist\InstallScriptUpdater.cmd" "%LOCALAPPDATA%\mobilmir.ru\ScriptUpdater"
	    SET "ScriptUpdaterDir=%%LOCALAPPDATA%%\mobilmir.ru\ScriptUpdater"
	    IF NOT EXIST "\\Srv0.office0.mobilmir\profiles$\Share\gpg\%Hostname%@rarus.robots.mobilmir.ru.asc" (
		ECHO ScriptUpdater ��⠭����� � LOCALAPPDATA. ��������, �� ���� gpg ᪮��஢����� � \\Srv0.office0.mobilmir\profiles$\Share\gpg, ���� ��祣� ࠡ���� �� �㤥�
		PAUSE
	    )
	)
    ) ELSE (
	rem /NP �ᥣ�� �� ᮧ����� �����, � �� ��������� 㪠�뢠�� �����
	SET "schtasksOptions=/RL HIGHEST"
	IF EXIST "D:\Mail\Thunderbird" (
	    SET "abDir=D:\Mail\Thunderbird\AddressBook"
	) ELSE SET "abDir=%ProgramData%\mobilmir.ru\AddressBook"
	SET "taskTemplate=AddressBook_download.xml"
	IF NOT DEFINED ScriptUpdaterDir CALL "%~dp0..\ScriptUpdater_dist\InstallScriptUpdater.cmd" & GOTO :Restart
    )
    
    CALL "%~dp0..\FindAutoHotkeyExe.cmd"
)
(
    MKDIR "%abDir%"
    SET "rcAutohotkeyExe=%AutohotkeyExe:"='%"
)
SET "runcmd=%rcAutohotkeyExe% '%ScriptUpdaterDir%\scriptUpdater.ahk' '%abDir%\business_contacts.mab' 'https://www.dropbox.com/s/0icvtif93c0dnap/business_contacts.mab.gpg?dl=1' 0"
CALL :strlen lenruncmd "%runcmd%"
IF %lenruncmd% GTR 261 (
    XCOPY "%~dp0AddressBook_download.ahk" "%ProgramData%\mobilmir.ru\AddressBook_download.ahk" /Y
    IF ERRORLEVEL 1 (
	XCOPY "%~dp0AddressBook_download.ahk" "%LOCALAPPDATA%\mobilmir.ru\AddressBook_download.ahk" /Y
	SET "runcmd=%rcAutohotkeyExe% '%LOCALAPPDATA%\mobilmir.ru\AddressBook_download.ahk'"
    ) ELSE SET "runcmd=%rcAutohotkeyExe% '%ProgramData%\mobilmir.ru\AddressBook_download.ahk'"
)
:schtasksAgain
(
    FOR %%A IN ("%~dp0optional\%taskTemplate%") DO SET "taskTemplateTime=%%~tA"
    ECHO.|%SystemRoot%\System32\schtasks.exe /Create /TN "mobilmir.ru\AddressBook_download" /XML "%~dp0optional\%taskTemplate%" /RU "%USERNAME%" /NP /F || GOTO :Failschtask
    %SystemRoot%\System32\schtasks.exe /Change /TN "mobilmir.ru\AddressBook_download" /TR "%runcmd%" || GOTO :Failschtask
    
    MKDIR "%ProgramData%\mobilmir.ru"
    ( ECHO %abDir%
    )>"%ProgramData%\mobilmir.ru\addressbookdir.txt.tmp"
    MOVE /Y "%ProgramData%\mobilmir.ru\addressbookdir.txt.tmp" "%ProgramData%\mobilmir.ru\addressbookdir.txt"
    IF ERRORLEVEL 1 (
	MKDIR "%LOCALAPPDATA%\mobilmir.ru"
	( ECHO %abDir%
	)>"%LOCALAPPDATA%\mobilmir.ru\addressbookdir.txt"
    ) ELSE DEL "%LOCALAPPDATA%\mobilmir.ru\addressbookdir.txt"
    %SystemRoot%\System32\schtasks.exe /Run /TN "mobilmir.ru\AddressBook_download"
    
    SET /A waitCount=30
    SET timeCurrentMAB=���
    ECHO �������� ����㧪� ���᭮� �����
)
:waitAB
(
    SET /A waitCount-=1
    PING 127.0.0.1 -n 2 >NUL 2>&1
    IF NOT EXIST "%abDir%\business_contacts.mab" IF %waitCount% GTR 0 GOTO :waitAB
    FOR %%A IN ("%abDir%\business_contacts.mab") DO SET "timeCurrentMAB=%%~tA"
)
(
    START "" %AutohotkeyExe% %~dp0..\Lib\RetailStatusReport.ahk "%taskTemplate%" "%taskTemplateTime%" "������ ���᭠� �����: %timeCurrentMAB%" "������� � ����� �����஢騪�: %runcmd%"
EXIT /B
)
:Failschtask <label>
(
    ECHO �訡�� %ERRORLEVEL% �� ����������/�������� �����.
    ECHO �������?
    ECHO [���� = ���, ���� ������ ��� ���짮��⥫� ��� ���������� ����� � �����஢騪]
    SET /P "USERNAME=> "
    IF NOT DEFINED USERNAME EXIT /B
GOTO :schtasksAgain
)
:strlen <resultVar> <stringVar>
(   
    rem https://stackoverflow.com/a/5841587
    setlocal EnableDelayedExpansion
    set "s=!%~2!#"
    set "len=0"
    for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!s:~%%P,1!" NEQ "" ( 
            set /a "len+=%%P"
            set "s=!s:~%%P!"
        )
    )
)
( 
    endlocal
    set "%~1=%len%"
    exit /b
)
