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
SET "DstDir=%~d0\Distributives"

IF NOT DEFINED ErrorCmd (
    IF "%RunInteractiveInstalls%"=="0" (
	SET "ErrorCmd=ECHO  & PING -n 30 127.0.0.1 >NUL & EXIT /B"
    ) ELSE (
	SET "ErrorCmd=PAUSE & EXIT /B"
    )
)

IF NOT EXIST %SystemDrive%\SysUtils\cygwin\rsync.exe CALL :unpackRsync

SET "compressMode=-z --compress-level=9"
route print | find "          0.0.0.0          0.0.0.0      192.168.1.1" /C && SET "compressMode="
)
(
ECHO args: %*
ECHO compressMode: %compressMode%
SET "SrcBaseURI=rsync://%DistributivesHost%/Distributives"
IF NOT "%~1"=="" (
    FOR %%A IN (%*) DO CALL :rsyncDistributives "%%~A"
    EXIT /B
)

FOR /R "%DstDir%" %%I IN (%syncFlagMasks%) DO CALL :rsyncDistributives "%%~dpI"
EXIT /B
)
:rsyncDistributives
(
rem %1 - local destination path without driveletter
rem source is determined with SrcBaseURI and part of destination:
rem %SrcBaseURI%\local_destination_without_?:\Distributives_prefix
SET "argDestDir=%~f1"
)
IF "%argDestDir:~-1%"=="\" SET "argDestDir=%argDestDir:~,-1%"
(
    IF "%lastCallSrc%" == "%argDestDir%" (
	ECHO %DATE% %TIME% Repeating call for "%argDestDir%", skipping
	EXIT /B
    )
    ECHO %DATE% %TIME% local dest: %argDestDir%
    SET "lastCallSrc=%argDestDir%"

    CALL :getRelPath relDestPath "%argDestDir%"
    IF "%argDestDir:~0,2%"=="\\" ( SET "icaclsDestDir=%argDestDir%" ) ELSE SET "icaclsDestDir=\\?\%argDestDir%"
)
(
    SET "cygpathRsyncSrc="
    ECHO %DATE% %TIME% Converting "%SrcBaseURI%\%relDestPath%\." to cygpath...
    FOR /F "usebackq delims=" %%A IN (`%SystemDrive%\SysUtils\cygwin\cygpath.exe "%SrcBaseURI%\%relDestPath%\."`) DO SET "cygpathRsyncSrc=%%~A"
    IF ERRORLEVEL 1 GOTO :CygpathError
    IF NOT DEFINED cygpathRsyncSrc GOTO :CygpathError
    SET "rulefiles="
    SET "recursion=-r"
)
PUSHD %1 || EXIT /B
(
    IF "%CD%"=="%SystemRoot%" @ECHO %DATE% %TIME% PUSHD ended up in SystemRoot & PAUSE & %ErrorCmd%
    IF "%CD:~1,9%"==":\Windows" @ECHO %DATE% %TIME% PUSHD ended up in a Windows dir & PAUSE & %ErrorCmd%
    IF "%CD:~1,9%"==":\" @ECHO %DATE% %TIME% PUSHD ended up in a drive root & PAUSE & %ErrorCmd%
    @rem TODO: includes still don't work
    IF EXIST ".sync.includes" SET rulefiles=%rulefiles% --include-from=.sync.includes
    IF EXIST ".sync.excludes" SET rulefiles=%rulefiles% --exclude-from=.sync.excludes
)
(
    CALL :ResetACL "%icaclsDestDir%" || (ECHO Resetting ownership & %SystemRoot%\System32\takeown.exe /F "%icaclsDestDir%" /D Y /R & CALL :ResetACL "%icaclsDestDir%")
    SET "rsyncError="
    ECHO %SystemDrive%\SysUtils\cygwin\rsync.exe -HLk %compressMode% --delete-delay --super -tmy8hP --exclude=.sync* --exclude=temp %recursion% %rulefiles% "%cygpathRsyncSrc%" .
    %SystemDrive%\SysUtils\cygwin\rsync.exe -HLk %compressMode% --delete-delay --super -tmy8hP --exclude=.sync* --exclude=temp %recursion% %rulefiles% "%cygpathRsyncSrc%" . || CALL :SetRsyncError
    POPD
    CALL :ResetACL "%icaclsDestDir%"
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
rem IF NOT DEFINED SetACLexe CALL "%configDir%_Scripts\find_exe.cmd" SetACLexe SetACL.exe
rem IF NOT DEFINED AutohotkeyExe CALL "%configDir%_Scripts\FindAutoHotkeyExe.cmd"
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

:getRelPath <varname> <fullpath>
SET "fallback=%~pnx2"
SET "fallback=%fallback:~14%"

SET /A "pathTokenNum=0"
:nextToken
SET /A "pathTokenNum+=1"
FOR /F "delims=\ tokens=%pathTokenNum%*" %%A IN ("%~2") DO (
    IF "%%~B"=="" (
	SET "%~1=%fallback%"
	EXIT /B
    )
    IF "%%~A"=="Distributives" (
	SET "%~1=%%~B"
	EXIT /B
    )
    ECHO Skipping: %%A
)
GOTO :nextToken

:strlen <resultVar> <stringVar>
(   
    setlocal EnableDelayedExpansion
    set "s=!%~2!#"
    set "len=0"
    for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!s:~%%P,1!" NEQ "" ( 
            set /a "len+=%%P"
            set "s=!s:~%%P!"
            ECHO len: !len! string: !s!
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
