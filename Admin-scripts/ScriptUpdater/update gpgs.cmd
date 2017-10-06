@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET exe7z="c:\Program Files\7-Zip\7z.exe"
SET gpgexe="D:\Users\LogicDaemon\AppData\Local\Programs\SysUtils\gnupg\gpg.exe"

RD /S /Q "%TEMP%\%~n0.tmp"
MKDIR "%TEMP%\%~n0.tmp"
)
PUSHD "%TEMP%\%~n0.tmp" && (
    rem MKDIR "Distributives\config\_Scripts"
    rem XCOPY "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\scriptUpdater.ahk" "Distributives\config\_Scripts\" /I
    %exe7z% x "\\Srv0.office0.mobilmir\profiles$\Share\config\Users\depts\D.7z" "Local_Scripts\*"
    
    REM следующую строку можно удалить 19.10.2017, т.к. везде, где авто-обновление работает, скрипт уже должен будет обновиться
    %exe7z% x -o"Local_Scripts\ScriptUpdater" "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\ScriptUpdater_dist\ScriptUpdater.7z"
    %exe7z% a SharedLocal.7z
    
    COPY \\Srv0.office0.mobilmir\1S\ShopBTS_InitialBase\MailLoader\dist.7z MailLoader-dist.7z
    
    COPY \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\ScriptUpdater_dist\ScriptUpdater.7z
    COPY \\Srv0.office0.mobilmir\profiles$\Share\config\Users\depts\Shortcuts.7z
    COPY \\Srv0.office0.mobilmir\profiles$\Share\config\Users\depts\Shortcuts_64bit.7z
    
    FOR %%A IN (*.*) DO (
	%gpgexe% -o "%%~A.curr" -d "%~dp0%%~nxA.gpg"
	ECHO Comparing "%%~A" and "%~dp0%%~nxA.gpg"
	C:\SysUtils\UnxUtils\cmp.exe -s "%%~A" "%%~A.curr" || CALL :Compare "%%~A" "%%~A.curr" || (
	    SET "a="
	    SET /P "a=Verify changes. Any text to sign, Enter to cancel >"
	    IF DEFINED a (
		%gpgexe% --sign "%%~A"
		MOVE /Y "%%~A.gpg" "%~dp0"
	    )
	)
	rem DEL "%%~A" "%%~A.curr"
    )
)
EXIT /B
:Compare
(
    IF "%~x1"==".7z" GOTO :CompareArcs
    IF "%~x1"==".zip" GOTO :CompareArcs
    IF "%~x1"==".rar" GOTO :CompareArcs
    
    rem C:\SysUtils\UnxUtils\diff.exe -bqdNTs %1 %2 || 
    "C:\Program Files (x86)\KDiff3\kdiff3.exe" %1 %2
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