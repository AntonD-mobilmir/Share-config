@(REM coding:CP866
@REM Automated software update scripts
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT DEFINED srcpath (
        ECHO srcpath not defined, quitting.
        EXIT /B 32767
    )

    @REM usage: %0 URL [distmask|""] 
    @REM input:
    ECHO 	Arguments: %*
    @REM 	%1	URL of page with links / or of file, in latter case use -N switch for wget
    @REM 	%2	file mask of distributive
    @REM 		if not set, %~nx1 is used (filename from URL)
    @REM 		if distfmask is set, %2 is skipped (next argument is %2)
    @REM 	%3*
    @REM 		arguments for wget. First is unquoted before passing to wget, others are passed "as is"
    @REM 		(disabled) if %3 begins with -N, "logfname=%~nx2.log" is added to wget arguments
    @REM 		default: "-m -l 1 -nd -e robots=off --no-check-certificate"
    ECHO 	srcpath="%srcpath%"
    @REM 		mandatory, it's destination for distributive file
    ECHO 	distcleanup="%distcleanup%"
    @REM 		if set to 1, distcleanup procedures are executed
    ECHO 	addToS_UScripts="%addToS_UScripts%", s_uscripts="%s_uscripts%", UseTimeAsVersion="%UseTimeAsVersion%"
    @REM 		use 0 to disable calling "%%s_uscripts%%\..\templates\_add_withVer.cmd". s_uscripts must also be defined. If UseTimeAsVersion=1, _add_withVer will not try reading version of setup to determine version if installed software, and will use filename datetime instead.
    ECHO 	findpath="%findpath%"
    @REM 		relative path for unix find, which performed when seeking %distfmask% for files to link
    ECHO 	findargs="%findargs%"
    @REM		arguments for find. Default: -name %distfmask%
    ECHO 	dstrename="%dstrename%"
    @REM		new name for downloaded file. Default: %distfname%
    ECHO 	logfname="%logfname%"
    @REM		or determined from other args if not set
    @REM 
    ECHO 	baseDistUpdateScripts="%baseDistUpdateScripts%"
    @REM 		and
    ECHO 	baseDistributives="%baseDistributives%"
    @REM 		determine relpath from srcpath and redirection of srcpath, and
    ECHO 	baseWorkdir="%baseWorkdir%"
    @REM 		and
    ECHO 	baseLogsDir="%baseLogsDir%"
    @REM 		are used with relpath for default values of workdir and logsDir

    IF NOT DEFINED xlnexe (
        IF EXIST %SystemDrive%\SysUtils\xln.exe (
            SET xlnexe="%SystemDrive%\SysUtils\xln.exe"
        ) ELSE IF EXIST "%~d0Distributives\Soft\PreInstalled\utils\xln.exe" (
            SET xlnexe="%~d0Distributives\Soft\PreInstalled\utils\xln.exe"
        ) ELSE SET "xlnexe=verify error"
    )

    IF NOT DEFINED findexe IF EXIST "%SystemDrive%\SysUtils\UnxUtils\find.exe" SET "findexe=%SystemDrive%\SysUtils\UnxUtils\find.exe"
    IF NOT DEFINED wgetexe IF EXIST "%SystemDrive%\SysUtils\wget.exe" SET wgetexe="%SystemDrive%\SysUtils\wget.exe"

    SETLOCAL ENABLEEXTENSIONS
    CALL "%~dp0_GetWorkPaths.cmd"
    rem srcpath with baseDistUpdateScripts replaced to baseDistributives
    rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
    rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
    rem logsDir - baseLogsDir with relpath (or nothing)

    SET rdistpath=%1

    @REM skiptokens: default suggestion is 1 argument for URL, and distmask is defined as env var (or distmask is "" on command line).
    @REM 		even in worst scenario, if distmask will become one of arguments for wget, we'll just get one more query to non-existing host
    SET "skiptokens=1"

    IF "%~1"=="" (
        ECHO Not enough arguments.
        ECHO Usage:
        ECHO %0 URL [disributiveFileMask ["wget parameters"] ]
        EXIT /B 32767
    )
)

@REM skiptokens: but if distmast wasn't specified with variable, probably it's on command line
IF "%distfmask%"=="" (
    @REM skiptokens: if distmask isn't determined till here, distmask wasn't defined as env var, and we've got one of cases:
    @REM 	* on the command line there was one argument only
    @REM 	* second argument on the command line was ""
    @REM 	in either case, we're going to skip second argument (to not feed wget with quoted empty string "")
    SET "skiptokens=2"
    IF "%~2"=="" (
	SET "distfmask=%~nx1"
    ) ELSE (
	SET "distfmask=%~2"
    )
)
@REM If there were no distfmask defined, no 2nd arg, and extension, just get any file
IF "%distfmask%"=="" SET "distfmask=*"

IF NOT "%~2"=="" (
    @REM everything after skiptokens are arguments for wget, we'll feed them to wget
    rem doesn't work well with spaces in any of arguments: FOR /F "usebackq tokens=%skiptokens%* delims= " %%I IN ('%*') DO SET "wgetparm=%%J"
    CALL :GetWgetArgsSkippingFirst %*
)
(
IF NOT DEFINED wgetparm SET "wgetparm=-m -l 1 -nd -e robots=off --no-check-certificate --unlink"
IF NOT DEFINED logfname GOTO :setDefaultLogFName
@REM Check if log filename contains unwanted characters
SET "checklogfname=%logfname:&=%"
)
SET "checklogfname=%checklogfname:*=%"
SET "checklogfname=%checklogfname:?=%"
SET "checklogfname=%checklogfname:/=%"
(
@REM if it does not, keep it; otherwise, use default log filename
IF "%checklogfname%"=="%logfname%" GOTO :keepLogFName
)
:setDefaultLogFName
SET "logfname=%logsDir%%~n0.log"
:keepLogFName
IF NOT EXIST "%workdir%" MKDIR "%workdir%"
ECHO wget -o "%logfname%" --progress=dot:giga %wgetparm% %rdistpath%
START "" /B /WAIT /D"%workdir%" %wgetexe% -o "%logfname%" --progress=dot:giga %wgetparm% %rdistpath%
(
SET "wgeterrorlevel=%ERRORLEVEL%"
IF DEFINED findpath ( CALL :CheckFindPath ) ELSE SET "findpath=."
IF NOT DEFINED findargs SET findargs=-name "%distfmask%"

CALL :InitRemembering
)
(
@REM In FOR's, use "%%~I" because Win2K and XP differently set quotes around iterator variable:
@REM 2K always outputs without quotes, but XP's 'FOR' double-quotes argument if it contains spaces.
IF DEFINED findexe FOR /F "usebackq delims=" %%I IN (`%findexe% "%workdir%%findpath%" %findargs%`) DO CALL :RememberIfLatest dstfname "%%~fI"
)
(
IF DEFINED dstfname CALL :linkdst "%dstfname%"
IF DEFINED s_uscripts IF NOT "%addToS_UScripts%"=="0" CALL "%s_uscripts%\..\templates\_add_withVer.cmd" "%dstfname%"

EXIT /B %wgeterrorlevel%
)

:linkdst
(
    SET "dstfname=%~nx1"
    IF DEFINED dstrename SET "dstfname=%dstrename%"
)
(
    IF "%distcleanup%"=="1" IF EXIST "%srcpath%%dstfname%" (
        SET "cleanup_action=DEL /Q /A-R-H-S"
        CALL "%~dp0distcleanup.cmd" "%~dp1%distfmask%" %1
	SET cleanup_action=CALL "%baseScripts%\mvold.cmd"
	CALL "%~dp0distcleanup.cmd" "%srcpath%%distfmask%" "%srcpath%%dstfname%"
    )
    %xlnexe% %1 "%srcpath%%dstfname%"||COPY /B /Y %1 "%srcpath%%dstfname%"
EXIT /B
)
:InitRemembering
(
    SET "LatestFile="
    SET "LatestDate=0000000000:00"
EXIT /B
)
:RememberIfLatest
(
    SET "CurrentFile=%~2"
    SET "CurrentDate=%~t2"
)
(
    @rem     01.12.2011 21:29
    SET "CurrentDate=%CurrentDate:~6,4%%CurrentDate:~3,2%%CurrentDate:~0,2%%CurrentDate:~11%"
)
    IF "%CurrentDate%" GEQ "%LatestDate%" (
	SET "LatestFile=%CurrentFile%"
	SET "LatestDate=%CurrentDate%"
    )
(
    SET "%~1=%LatestFile%"
EXIT /B
)
:CheckFindPath
    IF "%findpath:~-1%"=="\" SET "findpath=%findpath:~0,-1%"
(
    IF "%findpath:~0,1%"=="\" SET "findpath=%findpath:~1%"
EXIT /B
)
:GetWgetArgsSkippingFirst
    (
    SETLOCAL
    FOR /L %%I IN (1,1,%skiptokens%) DO SHIFT
    )
:AppendWgetArgs
    IF .%1==. (
	ENDLOCAL
	SET wgetparm=%wgetparm%
	EXIT /B
    )
    (
    SET wgetparm=%wgetparm% %1
    SHIFT
    GOTO :AppendWgetArgs
    )
