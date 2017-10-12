@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    FOR /F "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
:Restart
    FOR /F "usebackq delims=" %%A IN ("%ProgramData%\mobilmir.ru\ScriptUpdaterDir.txt") DO SET "ScriptUpdaterDir=%%~A"
    
    rem Check if admin (XP and higher)
    %SystemRoot%\System32\fltmc.exe >nul 2>&1
    IF ERRORLEVEL 1 (
	rem Not admin, /RL LIMITED is in the task template
	SET "taskTemplate=AddressBook_download_LOCALAPPDATA.xml"
	SET "schtasksOptions=/IT"
	SET "schedUserName=%USERNAME%"
	SET "abDir=%LOCALAPPDATA%\mobilmir.ru\AddressBook"
	IF NOT DEFINED ScriptUpdaterDir (
	    CALL "%~dp0..\ScriptUpdater_dist\InstallScriptUpdater.cmd" "%LOCALAPPDATA%\mobilmir.ru\ScriptUpdater" || PAUSE
	    SET "ScriptUpdaterDir=%%LOCALAPPDATA%%\mobilmir.ru\ScriptUpdater"
	)
    ) ELSE (
	SET "taskTemplate=AddressBook_download.xml"
	rem --in XML-- SET "schtasksOptions=/RL HIGHEST"
	IF EXIST "D:\Mail\Thunderbird" (
	    CALL "%~dp0..\AddUsers\AddUser_admin-task-scheduler.cmd" /LeaveExistingPwd
	    rem schedUserName schedUserPwd
	    SET "abDir=D:\Mail\Thunderbird\AddressBook"
	) ELSE (
	    SET "abDir=%ProgramData%\mobilmir.ru\AddressBook"
	)
	IF NOT DEFINED ScriptUpdaterDir (
	    CALL "%~dp0..\ScriptUpdater_dist\InstallScriptUpdater.cmd" || PAUSE
	    GOTO :Restart
	)
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
    IF DEFINED schedUserPwd (
	%SystemRoot%\System32\schtasks.exe /Create /TN "mobilmir.ru\AddressBook_download" /XML "%~dp0optional\%taskTemplate%" /RU "%schedUserName%" /RP "%schedUserPwd%" %schtasksOptions% /F || GOTO :Failschtask
	%SystemRoot%\System32\schtasks.exe /Change /TN "mobilmir.ru\AddressBook_download" /RU "%schedUserName%" /RP "%schedUserPwd%" %schtasksOptions% /TR "%runcmd%" || GOTO :Failschtask
    ) ELSE (
	rem /NP при создании задачи, если USERNAME==schedUserName а при изменении указывать нельзя
	ECHO.|%SystemRoot%\System32\schtasks.exe /Create /TN "mobilmir.ru\AddressBook_download" /XML "%~dp0optional\%taskTemplate%" /RU "%schedUserName%" %schtasksOptions% /F || GOTO :Failschtask
	%SystemRoot%\System32\schtasks.exe /Change /TN "mobilmir.ru\AddressBook_download" %schtasksOptions% /TR "%runcmd%" || GOTO :Failschtask
    )
    
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
    
    SET /A "waitCount=30"
    SET "timeCurrentMAB=нет"
    ECHO Ожидание загрузки адресной книги
)
:waitAB
@(
    SET /A waitCount-=1
    PING 127.0.0.1 -n 2 >NUL 2>&1
    IF NOT EXIST "%abDir%\business_contacts.mab" IF %waitCount% GTR 0 GOTO :waitAB
    FOR %%A IN ("%abDir%\business_contacts.mab") DO SET "timeCurrentMAB=%%~tA"

    IF DEFINED MailUserId IF DEFINED MailDomain IF NOT EXIST "\\Srv0.office0.mobilmir\profiles$\Share\gpg\%MailUserId%@%MailDomain%.asc" (
	ECHO Файла "\\Srv0.office0.mobilmir\profiles$\Share\gpg\%MailUserId%@%MailDomain%.asc" не существует.
	ECHO ScriptUpdater установлен, но, пока адресная книга не загружена с открытым ключом для этого компьютера, обновление адресной книги работать не будет!
	SET KeyNotFound="Файл не найден: \\Srv0.office0.mobilmir\profiles$\Share\gpg\%MailUserId%@%MailDomain%.asc"
    )
)
(
    START "" %AutohotkeyExe% %~dp0..\Lib\RetailStatusReport.ahk "%taskTemplate%" "%taskTemplateTime%" "Текущая адресная книга: %timeCurrentMAB%" "Команда в задаче планировщика: %runcmd%" %KeyNotFound%
EXIT /B
)
:Failschtask <label>
(
    ECHO Ошибка %ERRORLEVEL% при добавлении/изменени задачи.
    ECHO Повторить?
    ECHO [пусто = нет, либо введите имя пользователя для добавления задачи в планировщик]
    SET /P "schedUserName=> "
    IF NOT DEFINED schedUserName EXIT /B
    SET "schedUserPwd="
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
