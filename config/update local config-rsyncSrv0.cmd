@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS
    SET "srcpath=%~dp0"
    CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"

    IF NOT "%~1"=="" SET "configDir=%~1"
    SET "rsyncHost=Srv0.office0.mobilmir"
    IF NOT DEFINED configDir (
        IF DEFINED DefaultsSource CALL :getconfigDirFromDefaultsSource "%DefaultsSource%"
        IF NOT DEFINED configDir CALL "%~dp0_Scripts\copy_defaultconfig_to_localhost.cmd"
        IF NOT DEFINED configDir ECHO Место назначения не определено. Сначала стоит установить _get_defaultconfig_source.cmd & PAUSE & EXIT /B
    )
)
(
    IF "%configDir:~0,2%"=="\\" ECHO Папка конфигурации - в сети, обновлять можно только локальную папку! & PAUSE & EXIT /B
    IF NOT EXIST "%configDir%" MKDIR "%configDir%" || EXIT /B
    IF EXIST "%SystemDrive%\SysUtils\cygwin\cygpath.exe" IF EXIST "%SystemDrive%\SysUtils\cygwin\rsync.exe" (
	CALL "%ProgramData%\mobilmir.ru\Common_Scripts\waithost.cmd" %rsyncHost% 1 && CALL :RunRsync && EXIT /B
    )

    REM rsync failed, try xcopy
    REM needed for XCOPY %Distributives%\config
    CALL "%ProgramData%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd"
    IF NOT DEFINED Distributives IF "%srcpath:~0,2%"=="\\" SET "Distributives=%srcpath%.."
    IF NOT DEFINED Distributives CALL "%~dp0_Scripts\FindSoftwareSource.cmd"
)
(
    MKDIR "%configDir%"
    IF EXIST "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\*.*" XCOPY "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\*.*" "%configDir%" /D /E /C /I /R /H /K /Y && EXIT /B

    REM only continuing here if both rsync and xcopy failed or unavailable
    ECHO Локальная конфигурация не обновлена!>&2
EXIT /B 1
)
:RunRsync
(
    PUSHD "%configDir%" && (
	START "" /B %SystemRoot%\System32\schtasks.exe /S %rsyncHost% /Run /TN rsyncd
	CALL :rsync rsync://%rsyncHost%/config "%configDir%"
	POPD
    )
EXIT /B
)
:rsync <source> <dest> <rsync-args>
(
    SETLOCAL ENABLEEXTENSIONS
    IF NOT EXIST "%~2" CALL :TellNotExist %2
    IF NOT EXIST "%~1" CALL :TellNotExist %1
    
    SET "src=%~1"
    SET "dst=%~2"
)
(
    IF "%src:~-1%"=="\" SET "src=%src:~0,-1%"
    IF "%dst:~-1%"=="\" SET "dst=%dst:~0,-1%"
)
(
    FOR /F "usebackq delims=" %%I IN (`%SystemDrive%\SysUtils\cygwin\cygpath.exe "%dst%"`) DO SET "cygDst=%%~I"
    CALL :getArgsFromThird args %*
)
(
    %SystemRoot%\System32\takeown.exe /A /R /D Y /F "%dst%"
    %SystemRoot%\System32\icacls.exe "%dst%" /reset /T /C /Q
    ATTRIB -r -s -h "%dst%" /S /D /L
    
    rem -m, --prune-empty-dirs      prune empty directory chains from the file-list
    rem --modify-window=3601 
    %SystemDrive%\SysUtils\cygwin\rsync.exe -v --inplace -t -8 -h --progress -r --delete %args% "%src%" "%cygDst%" && %SystemRoot%\System32\icacls.exe "%dst%" /reset /T /C /Q
    rem без && теряется код ошибки rsync
    
    ENDLOCAL
EXIT /B
)

:getconfigDirFromDefaultsSource <DefaultsSource>
    SET "configDir=%~dp1"
(
    IF "%configDir:~0,2%"=="\\" SET "dest=" & EXIT /B 1
EXIT /B 0
)

:TellNotExist
(
    ECHO %1 не существует!
EXIT /B
)

:getArgsFromThird <varname> <arg1-to-skip> <arg2-to-gather> <arg3-to-gather>...
    SETLOCAL
:getNextArgFromThird
    SET "outvar=%outvar% %4"
    IF "%~5"=="" (
	ENDLOCAL
	SET "%~1=%outvar%"
	EXIT /B
    )
    SHIFT /4
GOTO :getNextArgFromThird
