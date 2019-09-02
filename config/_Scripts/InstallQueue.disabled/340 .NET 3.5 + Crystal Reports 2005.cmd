@(REM coding:CP866
IF NOT DEFINED logfile SET logfile="%SystemRoot%\Logs\%~n0.log"
IF NOT DEFINED configDir CALL :GetConfigDir
IF DEFINED PROCESSOR_ARCHITEW6432 SET "bcs=x64"
IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "bcs=x64"
REM bcs: bit capacity suffix
IF NOT DEFINED bcs SET "bcs=x32"
SET "WinISODir=\\Srv0.office0.mobilmir\Distributives\Images\OS\Windows"
)
(
    IF NOT DEFINED DistSourceDir CALL "%ConfigDir%_Scripts\FindSoftwareSource.cmd"
    IF NOT DEFINED AutohotkeyExe CALL "%ConfigDir%_Scripts\FindAutoHotkeyExe.cmd"
    
    CALL "%configDir%_Scripts\CheckWinVer.cmd" 6.4 && CALL :TryInstallingFromWinDist
) >>%logfile% 2>&1
(
    ECHO %DistSourceDir%\Updates\Windows\wsusoffline\cmd\DoUpdate.cmd
    PUSHD "%DistSourceDir%\Updates\Windows\wsusoffline\cmd" && (
	CALL DoUpdate.cmd /nobackup /instdotnet35
	POPD
    )
    
    ECHO "%DistSourceDir%\Soft com freeware\System\Virtual Machines Sandboxes\.NET\addons\install_CRRedist2005_x86.cmd"
    CALL "%DistSourceDir%\Soft com freeware\System\Virtual Machines Sandboxes\.NET\addons\install_CRRedist2005_x86.cmd"
EXIT /B
) >>%logfile% 2>&1
:TryInstallingFromWinDist
(
    FOR %%A IN (E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST "%%A:\sources\sxs" (
	CALL :InstnetfxFromWinDist %%A:
	GOTO :BreakImageSearch
    )
    IF NOT DEFINED netfx35sourceFound (
	CALL "%configDir%_Scripts\find7zexe.cmd"
	FOR /F "usebackq delims=" %%A IN (`DIR /B /AD /O-D "%WinISODir%\10*"`) DO FOR %%B IN ("%WinISODir%\%%~A\*_%OSbcSuf%.iso") DO (
	    CALL :TryInstallNetfxFromWinImage "%%~B"
	    GOTO :BreakImageSearch
	)
    )

:BreakImageSearch
    REM in case it all didn't help, install from Internet
    "%windir%\system32\dism.exe" /online /enable-feature /featurename:NetFX3 /All
    rem     sources\sxs\microsoft-windows-netfx3-ondemand-package.cab
    rem x64\sources\sxs\microsoft-windows-netfx3-ondemand-package.cab
    rem x86\sources\sxs\microsoft-windows-netfx3-ondemand-package.cab
EXIT /B
)
:GetConfigDir
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
(
    CALL :GetDir ConfigDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
:TryInstallNetfxFromWinImage
(
    %exe7z% e -aoa -o"%TEMP%\sources\sxs" -- "%~1" "%bcs%\sources\sxs\microsoft-windows-netfx3-ondemand-package.cab" "sources\sxs\microsoft-windows-netfx3-ondemand-package.cab"
    CALL :InstnetfxFromWinDist "%TEMP%\sources\sxs"
    EXIT /B
)
:InstnetfxFromWinDist <path>
(
    "%windir%\system32\dism.exe" /online /enable-feature /featurename:NetFX3 /All /Source:"%~1\sources\sxs" /LimitAccess
    rem Use /LimitAccess to prevent DISM from contacting WU/WSUS.
    rem Use /All to enable all parent features of the specified feature.
    EXIT /B
)
