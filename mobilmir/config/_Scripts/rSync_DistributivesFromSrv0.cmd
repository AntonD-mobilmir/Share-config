@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "DistributivesHost=192.168.1.80"
SET "syncFlagMasks=.sync*"
SET "DstDir=%~d0\Distributives"
IF NOT DEFINED exe7z CALL "%~dp0find7zexe.cmd"
IF NOT EXIST %SystemDrive%\SysUtils\cygwin\rsync.exe %exe7z% x -y -o%SystemDrive%\SysUtils -- "\\%DistributivesHost%\Distributives\Soft\PreInstalled\auto\SysUtils\SysUtils_rsync.7z"

SET "compressMode=-z --compress-level=9"
route print | find "          0.0.0.0          0.0.0.0      192.168.1.1" /C && SET "compressMode="
)
(
SET "SrcBaseURI=rsync://%DistributivesHost%/Distributives"
rem IF NOT "%~2"=="" CALL :strlen lenBaseDir %2
IF NOT "%~1"=="" (
    CALL :rsyncDistributives %1
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

IF .%lastCallSrc% == .%1 EXIT /B
SET lastCallSrc=%1

SET "argDestDir=%~1"
)
IF "%argDestDir:~-1%"=="\" SET "argDestDir=%argDestDir:~,-1%"
rem Can't replace with %a:=y% because there's colon after drive letter :(
rem FOR /F "usebackq delims=" %%A IN (`ECHO %%argDestDir:%DstBaseDir%^=%%`) DO SET relDestPath=%%A

rem IF DEFINED lenBaseDir CALL :getSubString relDestPath %lenBaseDir% argDestDir
IF NOT DEFINED lenBaseDir CALL :getRelPath relDestPath "%argDestDir%"
)
(
FOR /F "usebackq delims=" %%A IN (`%SystemDrive%\SysUtils\cygwin\cygpath.exe "%SrcBaseURI%\%relDestPath%\."`) DO SET cygpathRsyncSrc=%%A
IF ERRORLEVEL 1 PAUSE & EXIT /B
IF NOT DEFINED cygpathRsyncSrc PAUSE & EXIT /B

SET rulefiles=
SET recursion=-r
)
PUSHD %1 || EXIT /B
(
IF "%CD%"=="%SystemRoot%" @ECHO  & PAUSE & EXIT
@rem TODO: includes still don't work
IF EXIST ".sync.includes" SET rulefiles=%rulefiles% --include-from=.sync.includes
IF EXIST ".sync.excludes" SET rulefiles=%rulefiles% --exclude-from=.sync.excludes
)   
( 
%SystemDrive%\SysUtils\cygwin\rsync.exe -HLk %compressMode% --delete-delay --super -tmy8hP --exclude=.sync* --exclude=temp %recursion% %rulefiles% "%cygpathRsyncSrc%" .
POPD
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
