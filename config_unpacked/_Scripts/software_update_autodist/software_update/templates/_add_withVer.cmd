(REM coding:CP866
REM Input:
REM 	srcpath=%srcpath%
REM 	%%1=%1 silent updater to run (optional)
REM 	%%2=%2 updated version number
REM 	   or version number to suffix update caller filename (only if %1 defined)
REM	UseTimeAsVersion=%UseTimeAsVersion% if 1, version will not be read via getver from installer, but will be parsed from filename with appended datetime

REM If silent updater is not specified, there must be installer-script-file:
REM 	templates\UpdateCallerDirectory.*
REM or install_silently.*/update.*/reinstall.*/install.* in caller directory

    IF NOT DEFINED xlnexe (
	IF EXIST %SystemDrive%\SysUtils\xln.exe (
	    SET xlnexe="%SystemDrive%\SysUtils\xln.exe"
	) ELSE IF EXIST "%~d0Distributives\Soft\PreInstalled\utils\xln.exe" (
	    SET xlnexe="%~d0Distributives\Soft\PreInstalled\utils\xln.exe"
	) ELSE SET "xlnexe=verify error"
    )

    SETLOCAL ENABLEEXTENSIONS

    IF NOT DEFINED s_uScripts EXIT /B 1
    IF DEFINED srcpath SET "distDir=%srcpath%"

    IF NOT "%~2"=="" (
	SET "SilentUpdater=%~1"
	IF EXIST "%~2" (
	    SET "distDir=%~dp2"
	) ELSE (
	    SET "distDir=%~dp1"
	    SET "s_u_Aversion=%~2"
	)
	SHIFT
    )
)
(
    IF NOT DEFINED s_u_Aversion (
	IF EXIST "%~1" ( CALL :GetVersion %1 ) ELSE SET "s_u_Aversion=%~n1"
    )
    IF NOT DEFINED distDir (
	ECHO %0 %DATE% %TIME%: Received following arguments: %*
	ECHO %0 %DATE% %TIME%: distDir - Update Caller directory cannot be determined!
	EXIT /B 2
    )
    IF NOT DEFINED s_u_Aversion (
	ECHO %0 %DATE% %TIME%: Received following arguments: %*
	ECHO %0 %DATE% %TIME%: s_u_Aversion - Update Version cannot be determined!
	EXIT /B 2
    )
    
    IF NOT DEFINED UpdateScriptName (
        IF "%distDir:~-1%"=="\" (
            CALL :getLastComponentOfPath UpdateScriptName "%distDir:~0,-1%"
        ) ELSE (
            CALL :getLastComponentOfPath UpdateScriptName "%distDir%"
        )
    )
    ECHO %0 %DATE% %TIME%: Silent auto-update script will be written to s_uScripts ^(=%s_uScripts%^)
)
rem removing denied characters
SET "s_u_Aversion=%s_u_Aversion:\=_%"
SET "s_u_Aversion=%s_u_Aversion:/=_%"
SET "s_u_Aversion=%s_u_Aversion::=_%"
(
ECHO cleaned up s_u_Aversion: %s_u_Aversion%

SET SU_AScript="%s_uScripts%\%UpdateScriptName% %s_u_Aversion%.cmd"
IF DEFINED SilentUpdater GOTO :ScriptCallingSilentUpdater

REM Check if there is a template
IF EXIST "%~dp0%UpdateScriptName%.*" GOTO :UpdaterFromTemplate
REM Or there is already installer for older version
IF EXIST "%s_uScripts%\%UpdateScriptName%*.*" GOTO :AtLeastThereIsPrevCaller

rem If any of previous would worked, script won't go till here. This is fallback variant.
CALL :CheckForInstallerScript || ECHO %0 %DATE% %TIME%: No Auto-update method found, nothing added to s_uScripts!
EXIT /B
)

:CheckForInstallerScript
(
    FOR /D %%A IN ("%distDir:~0,-1%" "%distDir%..") DO (
        FOR %%B IN (update autoupdate) DO (
            FOR %%C IN ("%%~A\%%~B.ahk" "%%~A\%%~B.cmd") DO IF EXIST "%%~C" (
                SET "installerPath=%%~C"
                SET "installertype=%%~xC"
                GOTO :foundInstallerScript
            )
        )
    )
EXIT /B 2
)
:foundInstallerScript
(
    rem remove static component from distDir, replace with %%DIstributives%%
    IF /I "%installerPath:~1,16%"==":\Distributives\" (
	SET SilentUpdater="%%Distributives%%\%installerPath:~17%"
    ) ELSE (
	SET SilentUpdater="%installerPath%"
    )
GOTO :ScriptCallingSilentUpdater
)
:ScriptCallingSilentUpdater
(
    rem -cannot be here, checked before calling- MOVE /Y "%s_uScripts%\%UpdateScriptName%*.*" "%s_uScripts%\..\old\"
    (ECHO @^(REM coding:OEM
    ECHO REM Automatically written with "%~f0" on %DATE% %TIME% as fallback
    IF /I "%installertype%"==".ahk" (
	ECHO %%AutohotkeyExe%% /ErrorStdOut %SilentUpdater%
    ) ELSE IF /I "%installertype%"==".cmd" (
	ECHO CALL %SilentUpdater%
    ) ELSE ECHO %SilentUpdater%
    ECHO ^)
    )>%SU_AScript%
EXIT /B 0
)
:UpdaterFromTemplate
    MOVE "%s_uScripts%\%UpdateScriptName%*.*" "%s_uScripts%\..\old\"
    FOR %%I IN ("%~dp0%UpdateScriptName%.*") DO %xlnexe% "%%~I" %SU_AScript%||COPY /B /Y "%%~I" %SU_AScript%
EXIT /B

:AtLeastThereIsPrevCaller
    REN "%s_uScripts%\%UpdateScriptName%*.*" "%UpdateScriptName% %s_u_Aversion%.*"
EXIT /B

:getLastComponentOfPath
    SET %1=%~nx2
EXIT /B

:GetVersion
    SETLOCAL
    REM semi-universal procedure to get version no. (%s_u_Aversion%) from file (%1)
    IF "%UseTimeAsVersion%"=="1" (
	CALL :prepTimeSuffix %1
	GOTO :GetVersionFromFileName
    )
    FOR /F "usebackq tokens=1" %%V IN (`%SystemDrive%\SysUtils\lbrisar\getver.exe "%~1"`) DO SET "s_u_Aversion=%%~V"
(
    IF "%s_u_Aversion%"=="?" GOTO :GetVersionFromFileName
    IF "%s_u_Aversion%"=="" GOTO :GetVersionFromFileName
    ENDLOCAL
    SET "s_u_Aversion=%s_u_Aversion%"
    EXIT /B
)
:GetVersionFromFileName
(
    REM ignore extension
    SET "s_u_Aversion=%~n1"
    REM split filename by "-_ " and use last part as version
    SET "VerSplitter=-_ "
    SET /A RunCount=0
)
:GetVFFNAgain
(
    REM %%U - filename
    REM %%V - version
    IF NOT DEFINED s_u_Aversion EXIT /B 1
    IF %RunCount% GTR 100 EXIT /B 1
    SET /A RunCount+=1
    FOR /F "tokens=1* delims=%VerSplitter%" %%U IN ("%s_u_Aversion%") DO (
	IF "%%~V"=="" (
	    IF NOT DEFINED Curs_u_Aversion IF NOT "%VerSplitter%"=="." (
		REM there were no "-_ " in string, use "."
		SET "VerSplitter=."
		GOTO :GetVFFNAgain
	    )
	    ENDLOCAL
	    SET "s_u_Aversion=%s_u_Aversion% %verSuffix%"
	    EXIT /B
	) ELSE (
	    SET "Curs_u_Aversion=%%~V"
	)
    )
)
(
    SET "s_u_Aversion=%Curs_u_Aversion%"
    GOTO :GetVFFNAgain
)
:prepTimeSuffix
(
    SETLOCAL
    SET "v=%~t1"
    REM 18.08.2016 18:25
)
    SET "v=%v::=%"
    REM 18.08.2016 1825
(
    ENDLOCAL
    SET "verSuffix=%v:~-9,4%-%v:~-12,2%-%v:~-0,2%_%v:~-4%"
EXIT /B
)
