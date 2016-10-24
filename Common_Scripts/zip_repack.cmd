@(REM coding:CP866
REM Repacks .zip
REM usage: %0 [/R path] mask
REM /R path		scan path recursively
REM 			if there is only one arg after /R, it is taken as mask, not as path
REM Accepts masks
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
REM
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF NOT DEFINED comprOpt7z SET "comprOpt7z=-mx=9 -mtc=off -mcu=on -mfb=257"

IF "%~1"=="" (
    ECHO At least one argument required.
    EXIT /B 2
)
IF NOT DEFINED exe7z CALL :find7zexe
SET secondtry=
)
:mktempagain
SET "tempdest=%TEMP%\%~n0_temp%RANDOM%"
IF EXIST "%tempdest%" (
    IF "%secondtry%"=="1" (
	ECHO "%tempdest%" must not exist
	EXIT /B 2
    )
    SET "secondtry=1"
    GOTO :mktempagain
)

:checkArg
IF /I "%~1"=="/R" (
    rem Recursive, with if there is more than one argument after; otherwise, it's only mask
    IF %3.==. (
	SET ArgForFOR=%1 
    ) ELSE (
	SET ArgForFOR=%1 %2
	SHIFT
    )
    GOTO :shiftToNextArg
)
IF /I "%~1"=="/NK" (
    SET "nobackup=1"
    GOTO :shiftToNextArg
)

FOR %ArgForFOR% %%I IN (%1) DO CALL :process "%%~fI"

:shiftToNextArg
(
IF "%~2"=="" EXIT /B
SHIFT
GOTO :checkArg
)
:process
(
    MKDIR "%tempdest%"
    %exe7z% x -o"%tempdest%" -- "%~1"
    PUSHD "%tempdest%" && (
	%exe7z% a -tzip -r %comprOpt7z% "%~1.new"
	IF ERRORLEVEL 1 (
	    DEL "%~1.new"
	) ELSE (
	    IF NOT "%nobackup%"=="1" MOVE "%~1" "%~1.bak"
	    MOVE /Y "%~1.new" "%~1"
	)
	POPD
    )
    RD /S /Q "%tempdest%"
EXIT /B
)

:find7zexe
(
    FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command" /ve /reg:64`) DO CALL :checkDirFrom1stArg %%B && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CURRENT_USER\Software\7-Zip" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\7-Zip" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString" /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B

    CALL :findexe exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL :findexe exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" || (ECHO  & EXIT /B 9009)
EXIT /B
)

:checkDirFrom1stArg <arg1> <anything else>
    CALL :Check7zDir "%~dp1"
EXIT /B

:Check7zDir <dir>
    IF NOT "%~1"=="" SET "dir7z=%~1"
    IF "%dir7z:~-1%"=="\" SET "dir7z=%dir7z:~0,-1%"
    IF NOT EXIST "%dir7z%\7z.exe" EXIT /B 9009
    "%dir7z%\7z.exe" >NUL 2>&1 <NUL || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
    SET exe7z="%dir7z%\7z.exe"
EXIT /B

:findexe
    (
    SET locvar=%1
    )
    (
    REM checking simplest variant -- when executable in in %PATH%
    CALL :testexe %locvar% %2 & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    )
    :findexeNextPath
    (
	IF "%~3"=="" GOTO :testexe
	IF EXIST "%~3" FOR %%I IN ("%~3") DO CALL :testexe %locvar% "%%~I" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
	SHIFT /3
    GOTO :findexeNextPath
    )
    :testexe
    (
	IF "%~2"=="" EXIT /B 9009
	IF NOT EXIST "%~dp2" EXIT /B 9009
	"%~2" <NUL >NUL 2>&1
	IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
	SET %1=%2
    )
EXIT /B
