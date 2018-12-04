@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    FOR /F "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "Hostname=%%~J"
)
:Restart
(
    FOR /F "usebackq delims=" %%A IN ("%PROGRAMDATA%\mobilmir.ru\ScriptUpdaterDir.txt") DO SET "ScriptUpdaterDir=%%~A"
    IF NOT DEFINED ScriptUpdaterDir FOR /F "usebackq delims=" %%A IN ("%LOCALAPPDATA%\mobilmir.ru\ScriptUpdaterDir.txt") DO SET "ScriptUpdaterDir=%%~A"
    
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
	    IF EXIST "%LOCALAPPDATA%\mobilmir.ru\ScriptUpdater-PubKeys" (
                %SystemRoot%\explorer.exe /explore,"%LOCALAPPDATA%\mobilmir.ru\ScriptUpdater-PubKeys"
                ECHO Скопируйте ключ из "%LOCALAPPDATA%\mobilmir.ru\ScriptUpdater-PubKeys" в папку на сервере!
                PAUSE
	    )
	    SET "ScriptUpdaterDir=%LOCALAPPDATA%\mobilmir.ru\ScriptUpdater"
	    SET "rcScriptUpdaterDir=%%LOCALAPPDATA%%\mobilmir.ru\ScriptUpdater"
	)
    ) ELSE (
	SET "taskTemplate=AddressBook_download.xml"
	rem --in XML-- SET "schtasksOptions=/RL HIGHEST"
	IF EXIST "D:\Mail\Thunderbird" (
	    CALL "%~dp0..\AddUsers\AddUser_admin-task-scheduler.cmd" /LeaveExistingPwd
	    rem schedUserName schedUserPwd
	    SET "abDir=D:\Mail\Thunderbird\AddressBook"
	) ELSE (
	    SET "abDir=%PROGRAMDATA%\mobilmir.ru\AddressBook"
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
    IF NOT DEFINED rcScriptUpdaterDir SET "rcScriptUpdaterDir=%ScriptUpdaterDir:"='%"
)
SET "runcmd=%rcAutohotkeyExe% '%rcScriptUpdaterDir%\scriptUpdater.ahk' '%abDir%\business_contacts.mab' 'https://www.dropbox.com/s/0icvtif93c0dnap/business_contacts.mab.gpg?dl=1' 0"
rem Check if runcmd length is 262 chars or more, as 261 is max for /TR
IF NOT "%runcmd:~262,1%"=="" (
    XCOPY "%~dp0..\AddressBook_download.ahk" "%PROGRAMDATA%\mobilmir.ru\*.*" /Y
    IF ERRORLEVEL 1 (
	XCOPY "%~dp0..\AddressBook_download.ahk" "%LOCALAPPDATA%\mobilmir.ru\*.*" /Y
	SET "runcmd=%rcAutohotkeyExe% '%LOCALAPPDATA%\mobilmir.ru\AddressBook_download.ahk'"
    ) ELSE SET "runcmd=%rcAutohotkeyExe% '%PROGRAMDATA%\mobilmir.ru\AddressBook_download.ahk'"
)
:schtasksAgain
(
    FOR %%A IN ("%~dp0optional\%taskTemplate%") DO SET "taskTemplateTime=%%~tA"
    IF DEFINED schedUserPwd (
	%SystemRoot%\System32\schtasks.exe /CREATE /TN "mobilmir.ru\AddressBook_download" /XML "%~dp0optional\%taskTemplate%" /RU "%schedUserName%" /RP "%schedUserPwd%" %schtasksOptions% /F || GOTO :Failschtask
	%SystemRoot%\System32\schtasks.exe /CHANGE /TN "mobilmir.ru\AddressBook_download" /RU "%schedUserName%" /RP "%schedUserPwd%" %schtasksOptions% /TR "%runcmd%" || GOTO :Failschtask
    ) ELSE (
	rem /NP при создании задачи, если USERNAME==schedUserName а при изменении указывать нельзя
	ECHO.|%SystemRoot%\System32\schtasks.exe /CREATE /TN "mobilmir.ru\AddressBook_download" /XML "%~dp0optional\%taskTemplate%" /RU "%schedUserName%" %schtasksOptions% /F || GOTO :Failschtask
	%SystemRoot%\System32\schtasks.exe /CHANGE /TN "mobilmir.ru\AddressBook_download" %schtasksOptions% /TR "%runcmd%" || GOTO :Failschtask
    )
    
    MKDIR "%PROGRAMDATA%\mobilmir.ru"
    ( ECHO %abDir%
    )>"%PROGRAMDATA%\mobilmir.ru\addressbookdir.txt.tmp"
    MOVE /Y "%PROGRAMDATA%\mobilmir.ru\addressbookdir.txt.tmp" "%PROGRAMDATA%\mobilmir.ru\addressbookdir.txt"
    IF ERRORLEVEL 1 (
	MKDIR "%LOCALAPPDATA%\mobilmir.ru"
	( ECHO %abDir%
	)>"%LOCALAPPDATA%\mobilmir.ru\addressbookdir.txt"
    ) ELSE DEL "%LOCALAPPDATA%\mobilmir.ru\addressbookdir.txt"
    DEL "%PROGRAMDATA%\mobilmir.ru\addressbookdir.txt.tmp"
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

    IF DEFINED MailUserId IF DEFINED MailDomain IF NOT EXIST "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\gpg\%MailUserId%@%MailDomain%.asc" (
	ECHO Файла "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\gpg\%MailUserId%@%MailDomain%.asc" не существует.
	ECHO ScriptUpdater установлен, но, пока адресная книга, зашифрованная открытым ключом для этого компьютера, не выгружена в Dropbox, на этом компьютере она не расшифруется.
	SET KeyNotFound="Файл не найден: \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\gpg\%MailUserId%@%MailDomain%.asc"
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
