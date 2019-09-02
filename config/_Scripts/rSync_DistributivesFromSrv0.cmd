@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "DistributivesHost=Srv0.office0.mobilmir"
SET "syncFlagMasks=.sync*"

IF NOT DEFINED ErrorCmd (
    IF NOT DEFINED Unattended IF "%RunInteractiveInstalls%"=="0" SET "Unattended=1"
    IF DEFINED Unattended (
	SET "ErrorCmd=(ECHO  & PING -n 30 127.0.0.1 >NUL & EXIT /B)"
    ) ELSE (
	SET "ErrorCmd=(PAUSE & EXIT /B)"
    )
)

IF NOT EXIST %SystemDrive%\SysUtils\cygwin\rsync.exe CALL :unpackRsync

IF NOT DEFINED fuzzyDirs FOR %%A IN ("%~1.bak" "%~d0\Distributives.bak") DO IF EXIST "%%~A" CALL :AppendfuzzyDirs %%A
SET "compressMode=-z --compress-level=9"
route print | find "          0.0.0.0          0.0.0.0      192.168.1.1" /C && (SET "compressMode=" & SET "fuzzyDirs=")
)
(
ECHO args: %*
ECHO compressMode: %compressMode%
ECHO fuzzyDirs: %fuzzyDirs%
SET "SrcBaseURI=rsync://%DistributivesHost%/Distributives"
IF "%~1"=="" (
    IF "%CD%"=="%CD:\Distributives\=%" (
	IF NOT "%~d0"=="\\" FOR /R "%~dp0" %%I IN (%syncFlagMasks%) DO CALL :rsyncDistributives "%%~dpI"
    ) ELSE CALL :rsyncDistributives "%CD%"
) ELSE (
    FOR %%A IN (%*) DO CALL :rsyncDistributives "%%~A"
)

EXIT /B
)
:rsyncDistributives
(
rem %1 - local destination path
rem source is determined with SrcBaseURI and part of destination:
rem %SrcBaseURI%\local_destination_without_?:\Distributives_prefix
SET "argDestDir=%~f1"
IF "%~d1"=="\\" %ErrorCmd%
SET "argdestDrive=%~d1"
)
IF "%argDestDir:~-1%"=="\" SET "argDestDir=%argDestDir:~,-1%"
(
    IF "%lastCallSrc%" == "%argDestDir%" (
	ECHO %DATE% %TIME% Repeating call for "%argDestDir%", skipping
	EXIT /B
    )
    ECHO %DATE% %TIME% local dest: %argDestDir%
    SET "lastCallSrc=%argDestDir%"

    CALL :getRelativePath relDestPath "%argDestDir%"
    IF NOT DEFINED relDestPath %ErrorCmd%
    IF "%argDestDir:~0,2%"=="\\" ( SET "icaclsDestDir=%argDestDir%" ) ELSE SET "icaclsDestDir=\\?\%argDestDir%"
)
(
    IF DEFINED fuzzyDirs (
	SET fuzzyMode=-y
	rem  -y, --fuzzy                 find similar file for basis if no dest file
	CALL :AppendFuzzyArgs "/%relDestPath:\=/%" %fuzzyDirs:\=/%
    )
    
    SET "cygpathRsyncSrc="
    ECHO %DATE% %TIME% Converting "%SrcBaseURI%\%relDestPath%\." to cygpath...
    FOR /F "usebackq delims=" %%A IN (`%SystemDrive%\SysUtils\cygwin\cygpath.exe "%SrcBaseURI%\%relDestPath%\."`) DO SET "cygpathRsyncSrc=%%~A"
    IF ERRORLEVEL 1 GOTO :CygpathError
    IF NOT DEFINED cygpathRsyncSrc GOTO :CygpathError
    SET "rulefiles="
    SET "recursion=-r"
)
PUSHD %1 || %ErrorCmd%
(
    IF /I "%CD%"=="%SystemRoot%" @ECHO %DATE% %TIME% PUSHD ended up in SystemRoot & PAUSE & %ErrorCmd%
    IF /I "%CD:~1,9%"==":\Windows" @ECHO %DATE% %TIME% PUSHD ended up in a Windows dir & PAUSE & %ErrorCmd%
    IF /I "%CD:~1,9%"==":\" @ECHO %DATE% %TIME% PUSHD ended up in a drive root & PAUSE & %ErrorCmd%
    @rem TODO: includes still don't work
    IF EXIST ".sync.includes" SET rulefiles=%rulefiles% --include-from=.sync.includes
    IF EXIST ".sync.excludes" SET rulefiles=%rulefiles% --exclude-from=.sync.excludes
)
(
    SET "rsyncError="
    CALL :ResetACL "%icaclsDestDir%" || (ECHO Resetting ownership & (%SystemRoot%\System32\takeown.exe /F "%icaclsDestDir%" /D Y /R >NUL) & CALL :ResetACL "%icaclsDestDir%")
    ECHO Creating folder structure
    ECHO %SystemDrive%\SysUtils\cygwin\rsync.exe -HLk --ignore-existing -t8hP -f "+ */" -f "- *" -f "- temp/" %recursion% %rulefiles% "%cygpathRsyncSrc%" .
    %SystemDrive%\SysUtils\cygwin\rsync.exe -HLk --ignore-existing -t8hP -f "+ */" -f "- *" -f "- temp/" %recursion% %rulefiles% "%cygpathRsyncSrc%" . || CALL :SetRsyncError
    rem -m, --prune-empty-dirs      prune empty directory chains from the file-list
    CALL :ResetACL "%icaclsDestDir%"
    ECHO Syncing
    ECHO %SystemDrive%\SysUtils\cygwin\rsync.exe -HLk %compressMode% %fuzzyMode% -t8hP --delete-delay -f "- .sync*" -f "- temp/" %recursion% %rulefiles% "%cygpathRsyncSrc%" .
    %SystemDrive%\SysUtils\cygwin\rsync.exe -HLk %compressMode% %fuzzyMode% -t8hP --delete-delay -f "- .sync*" -f "- temp/" %recursion% %rulefiles% "%cygpathRsyncSrc%" . || CALL :SetRsyncError
    CALL :ResetACL "%icaclsDestDir%"
rem     ECHO Syncing again deleting excess files this time
rem     ECHO %SystemDrive%\SysUtils\cygwin\rsync.exe -HLk %compressMode% --delete-delay -t8hP -f "- .sync*" -f "- temp/" %recursion% %rulefiles% "%cygpathRsyncSrc%" .
rem     %SystemDrive%\SysUtils\cygwin\rsync.exe -HLk %compressMode% --delete-delay -t8hP -f "- .sync*" -f "- temp/" %recursion% %rulefiles% "%cygpathRsyncSrc%" . || CALL :SetRsyncError
rem     CALL :ResetACL "%icaclsDestDir%"
    POPD
IF NOT DEFINED rsyncError EXIT /B
)
EXIT /B %rsyncError%
:ResetACL <path>
(
    ECHO %DATE% %TIME% Resetting ACL for "%icaclsDestDir%"
    %SystemRoot%\System32\icacls.exe "%icaclsDestDir%" /reset /T /C /Q
    EXIT /B
)
:SetRsyncError
(
    SET "rsyncError=%ERRORLEVEL%"
    ECHO %DATE% %TIME% rsync returned error %ERRORLEVEL%
    EXIT /B %ERRORLEVEL%
)
:CygpathError
(
    ECHO %DATE% %TIME% cygpath returned error %ERRORLEVEL%
    IF DEFINED cygpathRsyncSrc ECHO Converted path: "%cygpathRsyncSrc%"
    %ErrorCmd% %ERRORLEVEL%
    EXIT /B %ERRORLEVEL%
)
:unpackRsync
IF NOT DEFINED exe7z CALL "%~dp0find7zexe.cmd" || CALL :callFind7zexe
(
%exe7z% x -y -o%SystemDrive%\SysUtils -- "\\%DistributivesHost%\Distributives\Soft\PreInstalled\auto\SysUtils\SysUtils_rsync.7z"
EXIT /B
)
:callFind7zexe
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
CALL :GetDir configDir "%DefaultsSource%"
(
IF NOT DEFINED exe7z CALL "%configDir%_Scripts\find7zexe.cmd"
EXIT /B
)
:GetDir
(
SET "%~1=%~dp2"
EXIT /B
)
:getSubString <outvar> <begin,end> <inputvar>
(   
    setlocal EnableDelayedExpansion
    set "s=!%~3!"
    for %%Q in (%2) do (
	set "out=!s:~%%Q!"
    )
)
( 
    endlocal
    set "%~1=%out%"
    exit /b
)

:getRelativePath <varname> <fullpath>
(
SETLOCAL
SET "destPath=%~f2"
CALL :strlen srcpathLen srcpath
rem Сначала проверка, не находится ли скрипт в той же папке, в которой лежит папка для синхронизации
rem если да, то относительный путь = подпапке относительно скрипта
)
FOR /F "usebackq delims=" %%A IN (`ECHO "%%destPath:~0,%srcpathLen%%%"`) DO IF /I "%%~A"=="%srcpath%" FOR /F "usebackq delims=" %%B IN (`ECHO "%%destPath:~%srcpathLen%%%"`) DO IF NOT "%%~B"=="" (
    ENDLOCAL
    SET "%~1=%%~B"
    EXIT /B
)
rem Иначе надо попробовать найти слово Distributives в пути
SET /A "pathTokenNum=1"
:getRelativePath_nextToken
(
    FOR /F "delims=\ tokens=%pathTokenNum%*" %%A IN ("%~2") DO (
	IF "%%~B"=="" (
	    %ErrorCmd%
	    EXIT /B
	)
	IF /I "%%~A"=="Distributives" (
	    ENDLOCAL
	    SET "%~1=%%~B"
	    EXIT /B
	)
	ECHO Skipping: %%A
    )
    SET /A "pathTokenNum+=1"
GOTO :getRelativePath_nextToken
)

:AppendFuzzyArgs <"/%relDestPath:\=/%"> <%fuzzyDirs:\=/%>
(
    rem      --compare-dest=DIR      also compare destination files relative to DIR
    rem      --copy-dest=DIR         ... and include copies of unchanged files
    rem      --link-dest=DIR         hardlink to files in DIR when unchanged
    IF "%~2"=="" EXIT /B
    IF /I "%~d2"=="%argdestDrive%" (
	IF EXIST "%~2%~1" (
	    SET "fuzzyMode=%fuzzyMode% "--link-dest=%~2%~1" "--link-dest=%~2""
	) ELSE SET "fuzzyMode=%fuzzyMode% "--link-dest=%~2""
    ) ELSE (
	IF EXIST "%~2%~1" (
	    SET "fuzzyMode=%fuzzyMode% "--copy-dest=%~2%~1" "--copy-dest=%~2""
	) ELSE SET "fuzzyMode=%fuzzyMode% "--copy-dest=%~2""
    )
    SHIFT /2
    GOTO :AppendFuzzyArgs
)

:AppendfuzzyDirs
(
SET "fuzzyDirs=%fuzzyDirs% %*"
EXIT /B
)

:strlen <resultVar> <stringVar>
(   
    setlocal EnableDelayedExpansion
    set "s=!%~2!#"
    set "len=0"
    for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!s:~%%P,1!" NEQ "" ( 
            set /a "len+=%%P"
            set "s=!s:~%%P!"
            rem ECHO len: !len! string: !s!
        )
    )
)
( 
    endlocal
    set "%~1=%len%"
    exit /b
)

@rem --dry-run
@rem http://www.mediacollege.com/cgi-bin/man/page.cgi?topic=rsync
@REM  -R, --relative              use relative path names
@rem  -W, --whole-file            copy files whole (w/o delta-xfer algorithm)
@REM  -l, --links                 copy symlinks as symlinks
@REM  -L, --copy-links            transform symlink into referent file/dir
@REM      --copy-unsafe-links     only "unsafe" symlinks are transformed
@REM      --safe-links            ignore symlinks that point outside the source tree
@REM  -k, --copy-dirlinks         transform symlink to a dir into referent dir
@REM  -K, --keep-dirlinks         treat symlinked dir on receiver as dir
@REM  -H, --hard-links            preserve hard links

@REM -z, --compress              compress file data during the transfer
@REM     --compress-level=NUM    explicitly set compression level (max 9)

@REM -W, --whole-file            copy files whole (without delta-xfer algorithm)
@REM -P     			  The -P option is equivalent to --partial --progress


rem http://stackoverflow.com/questions/5837418/how-do-you-get-the-string-length-in-a-batch-file
