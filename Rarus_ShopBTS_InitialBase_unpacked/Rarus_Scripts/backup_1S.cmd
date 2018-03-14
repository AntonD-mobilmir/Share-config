@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF NOT DEFINED ProgramData SET "ProgramData=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"

    SET "srcdir=%~1"
    IF NOT DEFINED srcdir SET "srcdir=D:\1S\Rarus\ShopBTS"
    
    IF NOT DEFINED destdir CALL "%~dp0_rarus_backup_get_files.cmd" || CALL "%ProgramData%\mobilmir.ru\_rarus_backup_get_files.cmd" || CALL "%SystemDrive%\Local_Scripts\_rarus_backup_get_files.cmd"
    CALL :Findzpaq || CALL :Find7z || GOTO :ExitWithError
    SET "Switches7z=-slp -bd -mqs=on"
    rem -m0=LZMA2:a=1:d22:fb=64
    SET "datey=%DATE:~-4,4%"
    SET "datem=%DATE:~-4,4%-%DATE:~-7,2%"
    SET "dated=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%"

    SET "exclusionszpaq=-not *:*:$DATA -not Backup -not Exchange -not ExtForms/Scripts -not ExtForms/post -not ExtForms/MailLoader -not NEW_STRU -not Shared -not *.rar -not *.7z -not *.LCK -not *.cdx -not !*.flag -not sendEmail* -not zpaq*"
    SET "exclusions7z=-x!Backup -x!Exchange -x!ExtForms/Scripts -x!ExtForms/post -x!ExtForms/MailLoader -x!NEW_STRU -x!Shared -xr!*.rar -xr!*.7z -xr!*.LCK -xr!*.cdx -x!*.flag -x!sendEmail* -x!zpaq*"

    SET "flagChar=?"
    FOR /F "usebackq tokens=2 delims==" %%I IN (`FTYPE AutoHotkeyScript`) DO CALL :Get1stToken ahkexe %%I
)
(
    START "" /LOW %ahkexe% /ErrorStdOut "%~dp0backup_1S_RemoveOld.ahk" >>"%destDir%-cleanup.log" 2>&1
    PUSHD "%srcdir%" || (CALL :ExitWithError Не удалось перейти в исходную папку & EXIT /B)
    IF NOT EXIST "%destdir%" CALL :ExitWithError "%destdir%" "не существует" & EXIT /B
    SET "destfname=ShopBTS_%datem%.7z"
    SET "destdname=ShopBTS_%dated%.7z"
    ECHO [.] %DATE% %TIME% Начало архивации "%srcdir%"
    (
	ECHO.
	ECHO [.] %DATE% %TIME% Starting archiving of "%srcdir%"
    )>>"%rarusbackuplogfile%"
    CALL :MakeArchive >"%rarusbackupflag%"
    IF ERRORLEVEL 2 CALL :ExitWithError "при создании архива" & EXIT /B
    CALL :DelBackupFlag
    IF DEFINED arc7zFName CALL :TestRename7zArchive
    POPD
    IF DEFINED remoteDestDir (
	MKDIR "%remoteDestDir%"
	ECHO Y|XCOPY "%destdir%" "%remoteDestDir%" /M /E /I /G /H /Y /F
	MOVE /Y "%remoteDestDir%-cleanup.log" "%remoteDestDir%-cleanup.log.bak"
	START "" /LOW %ahkexe% /ErrorStdOut "%~dp0backup_1S_RemoveOld.ahk" "%remoteDestDir%" >"%remoteDestDir%-cleanup.log" 2>&1
    )
    FOR %%A IN ("%rarusbackuplogfile%" "%destDir%-cleanup.log") DO IF %%~zA GTR 1048576 MOVE /Y "%%~A" "%%~A.bak"
    EXIT /B
)

:MakeArchive
(
    IF DEFINED zpaqexe (
	ECHO [+] %DATE% %TIME% Добавление к архиву zpaq
	ECHO [+] %DATE% %TIME% Appending zpaq archive>>"%rarusbackuplogfile%"
	START "zpaq a" /B /WAIT /NORMAL %zpaqexe% a "%destdir%\%datey%.zpaq" * -m34 %exclusionszpaq% >>"%rarusbackuplogfile%" 2>&1
    ) ELSE ( 	REM Full archive monthly & differential daily
	IF EXIST "%destdir%\%destfname%" ( REM differential archiving if archive dont exist
	    IF NOT EXIST "%destdir%\%destdname%" (
		SET "arc7zFName=%destdir%\%destdname%"
		ECHO [-] %DATE% %TIME% Создание дифференциального архива
		ECHO [-] %DATE% %TIME% Making differential archive>>"%rarusbackuplogfile%"
		START "7z a diff" /B /WAIT /NORMAL %exe7z% a -r %Switches7z% -u- -up0q3z0!"%destdir%\%destdname%.tmp" %exclusions7z% -x!SYSLOG -- "%destdir%\%destfname%" *>>"%rarusbackuplogfile%" 2>&1
	    ) ELSE (
		ECHO [*] %DATE% %TIME% "%destdir%\%destdname%" уже существует
		ECHO [*] %DATE% %TIME% "%destdir%\%destdname%" already exist>>"%rarusbackuplogfile%"
		EXIT /B 1
	    )
	) ELSE ( REM otherwise full archive
	    SET "arc7zFName=%destdir%\%destfname%"
	    ECHO [+] %DATE% %TIME% Создание полного архива
	    ECHO [+] %DATE% %TIME% Making full archive>>"%rarusbackuplogfile%"
	    START "7z a full" /B /WAIT /NORMAL %exe7z% a -r %Switches7z% %exclusions7z% -- "%destdir%\%destfname%.tmp" *>>"%rarusbackuplogfile%" 2>&1
	)
    )
EXIT /B
)
:TestRename7zArchive
(
    %exe7z% t -bd -- "%arc7zFName%.tmp" >>"%rarusbackuplogfile%" 2>&1
    IF ERRORLEVEL 2 (
	CALL :ExitWithError "При тестировании архива" "%arc7zFName%.tmp"
    ) ELSE REN "%arc7zFName%.tmp" *.
EXIT /B
)

:Findzpaq
(
    SET "OS64bit="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	SET "OS64bit=1"
	SET zpaqexe="%ProgramFiles%\zpaq\zpaq64.exe"
    ) ELSE IF DEFINED PROCESSOR_ARCHITEW6432 (
	SET "OS64bit=1"
	SET zpaqexe="%ProgramW6432%\zpaq\zpaq64.exe"
    ) ELSE SET zpaqexe="%ProgramFiles%\zpaq\zpaq.exe"
)
(
    IF EXIST %zpaqexe% EXIT /B 0
    SET "zpaqexe="
    IF NOT DEFINED configDir CALL :GetDir configDir "%DefaultsSource%"
)
(
    IF DEFINED OS64bit CALL "%configDir%_Scripts\find_exe.cmd" zpaqexe zpaq.exe
    IF NOT DEFINED zpaqexe CALL "%configDir%_Scripts\find_exe.cmd" zpaqexe zpaq.exe
    EXIT /B
)
:Find7z
    IF NOT DEFINED configDir CALL :GetDir configDir "%DefaultsSource%"
(
    CALL "%configDir%_Scripts\find7zexe.cmd" || CALL "%configDir%_Scripts\find_exe.cmd" exe7z "%configDir%..\Soft\PreInstalled\utils\7za.exe" || CALL :LogError "Не найден 7-Zip"
EXIT /B
)
:ExitWithError <text>
(
    IF ERRORLEVEL 1 (
	SET "flagChar=*"
	IF ERRORLEVEL 2 SET "flagChar=!"
	SET "ExitErrorLevel=%ERRORLEVEL%"
    ) ELSE (
	SET "flagChar=."
	SET "ExitErrorLevel=1
    )
    IF NOT "%~1"=="" CALL :LogError %*
    SET "flagChar=?"
    CALL :DelBackupFlag
    ECHO [!] %DATE% %TIME% Резервное копирование не выполнено
    ECHO [!] %DATE% %TIME% Backup not completed>>"%rarusbackuplogfile%"
    POPD
)
EXIT %ExitErrorLevel%
:DelBackupFlag
(
    ECHO [_] %DATE% %TIME% Удаление флага архивации "%rarusbackupflag%"
    DEL "%rarusbackupflag%" || CALL :LogError при удалении флага архивации
    EXIT /B
)
:LogError <text>
(
    ECHO [%flagChar%] %DATE% %TIME% Ошибка %ERRORLEVEL% %*
    (
    ECHO [%flagChar%] %DATE% %TIME% Error %ERRORLEVEL% %*
    ) >>"%rarusbackuplogfile%"
    EXIT /B %ERRORLEVEL%
)
:Get1stToken
(
    SET %1="%~2"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
