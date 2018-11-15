@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    
    REM IF NOT DEFINED configDir CALL :findconfigDir
    SET "configDir=\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\"
    IF NOT DEFINED exe7z CALL :RunFromConfig "_Scripts\find7zexe.cmd" || CALL :SetFirstExistingExe exe7z "%~dp0..\..\PreInstalled\utils\7za.exe" || EXIT /B
    CALL :SetFirstExistingExe gpgexe "%LocalAppData%\Programs\SysUtils\gnupg\gpg.exe" || IF NOT DEFINED gpgexe CALL :RunFromConfig "_Scripts\findgpgexe.cmd" || EXIT /B

    RD /S /Q "%TEMP%\%~n0.tmp"
    MKDIR "%TEMP%\%~n0.tmp"
)
PUSHD "%TEMP%\%~n0.tmp" && (
    %exe7z% x "%configDir%Users\depts\D.7z" "Local_Scripts\*"
    
    %exe7z% a SharedLocal.7z
    
    COPY /B "\\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\MailLoader\dist.7z" MailLoader-dist.7z
    
    COPY /B "%configDir%_Scripts\ScriptUpdater_dist\ScriptUpdater.7z"
    COPY /B "%configDir%Users\depts\Shortcuts.7z"
    COPY /B "%configDir%Users\depts\Shortcuts_64bit.7z"
    
    COPY /B "%configDir%_Scripts\software_update_autodist\downloader-dist.7z" "software_update_autodist downloader-dist.7z"
    COPY /B "%configDir%_Scripts\software_update_autodist\software_update.7z" "software_update_autodist software_update.7z"
    
    FOR %%A IN (*.*) DO (
        %gpgexe% -o "%%~A.curr" -d "%~dp0%%~nxA.gpg"
        ECHO Comparing "%%~A" and "%~dp0%%~nxA.gpg"
        C:\SysUtils\UnxUtils\cmp.exe -s "%%~A" "%%~A.curr" || CALL :Compare "%%~A" "%%~A.curr" || (
            SET "a="
            SET /P "a=Verify changes. Non-empty string to sign, Enter to cancel >"
            IF DEFINED a (
                %gpgexe% --sign "%%~A"
                MOVE /Y "%%~A.gpg" "%~dp0"
            )
        )
        rem DEL "%%~A" "%%~A.curr"
    )
    POPD
    EXIT /B
)
:Compare
(
    IF "%~x1"==".7z" GOTO :CompareArcs
    IF "%~x1"==".zip" GOTO :CompareArcs
    IF "%~x1"==".rar" GOTO :CompareArcs
    
    rem C:\SysUtils\UnxUtils\diff.exe -bqdNTs %1 %2 || 
    IF NOT EXIST %1 (
	ECHO %1 not exist
    ) ELSE IF NOT EXIST %2 (
	ECHO %2 not exist
    ) ELSE "C:\Program Files (x86)\KDiff3\kdiff3.exe" %1 %2
    EXIT /B
:CompareArcs
    RD /S /Q "%~1.new"
    RD /S /Q "%~1.old"
    %exe7z% x -o"%~1.new" -- %1
    %exe7z% x -o"%~1.old" -- %2
    
    rem -w  --ignore-all-space  Ignore all white space.
    rem -b  --ignore-space-change  Ignore changes in the amount of white space.
    rem -q  --brief  Output only whether files differ.
    rem -d  --minimal  Try hard to find a smaller set of changes.
    rem -T  --initial-tab  Make tabs line up by prepending a tab.
    rem -r  --recursive  Recursively compare any subdirectories found.
    rem -N  --new-file  Treat absent files as empty.
    rem -s  --report-identical-files  Report when two files are the same.
    C:\SysUtils\UnxUtils\diff.exe -bqdNTr "%~1.new" "%~1.old" || START "" /B "C:\Program Files (x86)\KDiff3\kdiff3.exe" "%~1.new" "%~1.old"
    EXIT /B
)

:RunFromConfig
IF NOT DEFINED configDir CALL :findconfigDir
(
    IF "%~x1"==".cmd" (
        CALL "%configDir%"%*
    ) ELSE "%configDir%"%*
    EXIT /B
)
:SetFirstExistingExe <varname> <path1> <path2> <...>
(
    IF EXIST %2 (
        SET %1=%2
        EXIT /B
    )
    IF "%~3"=="" EXIT /B 1
    SHIFT /2
    GOTO :SetFirstExistingExe
)
:findconfigDir
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
(
    CALL :GetDir configDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
