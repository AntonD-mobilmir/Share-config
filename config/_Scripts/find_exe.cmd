@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

GOTO :preserveEnv
)
:findexe
    (
    REM in:
    REM %1 variable which will get location
    REM %2 executable file name with optional suggested path
    REM %3... additional paths with filename (including masks) to look through
    REM %findExeTestExecutionOptions%	parameters to pass to executable when trying to run it to ensure quiet unattended exit
    REM %pathAppendSubpath%	subpath which will be appended to %PATH% with dir-to-found-executable prefix. For example, if sed.exe is in C:\SysUtils, and it requires libintl3.dll, which is in C:\SysUtils\libs. SET pathAppendSubpath=libs before calling the function.
    
    REM out:
    REM !%1! Quoted path to requested executable. If not found, var contents not changed.
    REM ERRORLEVEL 3 The system cannot find the path specified.
    REM ERRORLEVEL 9009 'test.exe' is not recognized as an internal or external command, operable program or batch file.

    SET "locvar=%~1"
    SET "seekforexecfname=%~nx2"
    )
    (
    REM checking simplest variant -- when suggested path exists or executable is in %PATH%
    FOR /D %%I IN ("%~dp2") DO IF EXIST "%%~I%seekforexecfname%" CALL :testexe %locvar% "%%~I%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% %2 & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    
    REM checking paths suggestions
    IF DEFINED utilsdir CALL :testexe %locvar% "%utilsdir%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    
    FOR /R "%SystemDrive%\SysUtils" %%I IN (.) DO IF EXIST "%%~I\%seekforexecfname%" CALL :testexe %locvar% "%%~I\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    
    REM following is relative to script-dir. When copying inline to other scripts, replace %~dp0 with %srcpath% and correct paths
    CALL :testexe %locvar% "%~dp0..\..\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "%~dp0..\..\..\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )

    REM fallback options
    CALL :testexe %locvar% "\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\localhost\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\Srv0.office0.mobilmir\profiles$\Share\Program Files\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )

    REM only for a script running from \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts
    CALL :testexe %locvar% "%~dp0..\..\..\..\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "%~dp0..\..\Program Files\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
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
	IF NOT EXIST "%~2" EXIT /B 9009
	SET "PATH=%PATH%;%~dp2"
	"%~2" %findExeTestExecutionOptions% <NUL >NUL 2>&1
	REM SET "PATH=%PATH%" restores PATH to one which was at start of the block
	IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 SET "PATH=%PATH%" & EXIT /B
	SET %~1="%~2"
EXIT /B
    )

:preserveEnv
(
    REM this is wrapper to preserve environment and only modify %1 on return
    REM usually this is not needed when copy-pasting the function to another script
    SETLOCAL ENABLEEXTENSIONS
)
:addanotherpath
    IF NOT "%~3"=="" (
	SET morePaths=%morePaths% %3
	SHIFT /3
	GOTO :addanotherpath
    )
    CALL :findexe outvar %2 %morePaths% || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
(
    ENDLOCAL
    SET %~1=%outvar%
    SET "PATH=%PATH%"
    EXIT /B
)
