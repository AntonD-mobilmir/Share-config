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
	rem Not admin
	SET "schPassSw=/IT"
	SET "abDir=%LOCALAPPDATA%\mobilmir.ru\AddressBook"
	SET "taskTemplate=AddressBook_download.xml"
	IF NOT DEFINED ScriptUpdaterDir (
	    CALL "%~dp0..\ScriptUpdater_dist\InstallScriptUpdater.cmd" "%LOCALAPPDATA%\mobilmir.ru\ScriptUpdater"
	    SET "ScriptUpdaterDir=%%LOCALAPPDATA%%\mobilmir.ru\ScriptUpdater"
	    IF NOT EXIST "\\Srv0.office0.mobilmir\profiles$\Share\gpg\%Hostname%@rarus.robots.mobilmir.ru.asc" (
		ECHO ScriptUpdater установлен в LOCALAPPDATA. Убедитесь, что ключи gpg скопировались в \\Srv0.office0.mobilmir\profiles$\Share\gpg, иначе ничего работать не будет
		PAUSE
	    )
	)
    ) ELSE (
	SET "schPassSw=/NP"
	IF EXIST "D:\Mail\Thunderbird" (
	    SET "abDir=D:\Mail\Thunderbird\AddressBook"
	) ELSE SET "abDir=%ProgramData%\mobilmir.ru\AddressBook"
	SET "taskTemplate=AddressBook_download_admin.xml"
	IF NOT DEFINED ScriptUpdaterDir CALL "%~dp0..\ScriptUpdater_dist\InstallScriptUpdater.cmd" & GOTO :Restart
    )
    
    CALL "%~dp0..\FindAutoHotkeyExe.cmd"
)
(
    MKDIR "%abDir%"
    SET "AutohotkeyExe=%AutohotkeyExe:"='%"
)
SET "runcmd=%AutohotkeyExe% '%ScriptUpdaterDir%\scriptUpdater.ahk' '%abDir%\business_contacts.mab' 'https://www.dropbox.com/s/0icvtif93c0dnap/business_contacts.mab.gpg?dl=1' 0"
CALL :strlen lenruncmd "%runcmd%"
IF %lenruncmd% GTR 261 (
    XCOPY "%~dp0AddressBook_download.ahk" "%ProgramData%\mobilmir.ru\AddressBook_download.ahk" /Y
    IF ERRORLEVEL 1 (
	XCOPY "%~dp0AddressBook_download.ahk" "%LOCALAPPDATA%\mobilmir.ru\AddressBook_download.ahk" /Y
	SET "runcmd=%AutohotkeyExe% '%LOCALAPPDATA%\mobilmir.ru\AddressBook_download.ahk'"
    ) ELSE SET "runcmd=%AutohotkeyExe% '%ProgramData%\mobilmir.ru\AddressBook_download.ahk'"
)
:sctasksAgain
(
    %SystemRoot%\System32\schtasks.exe /Create /TN "mobilmir.ru\AddressBook_download" /XML "%~dp0optional\%taskTemplate%" /RU "%USERNAME%" %schPassSw% /F || GOTO :Failschtask
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
EXIT /B
)
:Failschtask <label>
(
    ECHO Ошибка %ERRORLEVEL% при добавлении/изменени задачи.
    ECHO Повторить?
    ECHO [пусто = нет, либо введите имя пользователя для добавления задачи в планировщик]
    SET /P "USERNAME=> "
    IF NOT DEFINED USERNAME EXIT /B
GOTO :sctasksAgain
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
