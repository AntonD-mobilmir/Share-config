@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF DEFINED ProgramFiles^(x86^) (SET "lProgramFiles=%ProgramFiles(x86)%") ELSE SET "lProgramFiles=%ProgramFiles%"

SET "argv=%~1"
)
(
SET "argflag=%argv:~,1%"
SET "option=%argv:~1%"
)
IF "%argflag%"=="/" (
    SHIFT
    GOTO :arg_%option%
    EXIT /B 1
)

:arg_Import
    (
    IF NOT DEFINED RegConfigName SET "RegConfigName=%~1"
    IF NOT DEFINED RegConfigName SET "RegConfigName=TeamViewer_host.reg"
    )
    IF NOT EXIST "%RegConfigName%" (
	IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
	rem only finding 7z here because it's only needed to extract regconfig from defaultssource location. Otherwise, plain pre-extracted REG is used.
	IF NOT DEFINED exe7z CALL :find7zexe
    )
    IF NOT EXIST "%RegConfigName%" (
	SET "del=1"
	%exe7z% e -aoa -y -o"%TEMP%" -- "%DefaultsSource%" "TeamViewer\%RegConfigName%"
	SET "RegConfigName=%TEMP%\%RegConfigName%"
    )
    (
    %SystemRoot%\System32\reg.exe IMPORT "%RegConfigName%" /reg:32
    IF "%del%"=="1" DEL "%RegConfigName%"
    
    IF DEFINED debug PAUSE
    EXIT /B
    )
:arg_PostInstall
(
    IF NOT DEFINED RegConfigName SET "RegConfigName=%~1"
    IF NOT DEFINED RegConfigName SET "RegConfigName=TeamViewer_host.reg"
    REM Posting data to TeamViewer Install Info form
    IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
    IF NOT DEFINED AutohotkeyExe CALL :FindAutohotkeyExe
    SET "TVProgramFiles=%ProgramFiles(x86)%\TeamViewer\Version5"
)
    IF NOT EXIST "%TVProgramFiles%\TV.dll" SET "TVProgramFiles=%ProgramFiles%\TeamViewer\Version5"
(
    IF DEFINED AutohotkeyExe START "" /B %AutohotkeyExe% /ErrorStdOut "%srcpath%PostFormData.ahk"
    "%windir%\System32\netsh.exe" advfirewall firewall add rule name="Teamviewer Remote Control Application" dir=in action=allow program="%TVProgramFiles%\TeamViewer.exe" edge=yes
    "%windir%\System32\netsh.exe" advfirewall firewall add rule name="Teamviewer Remote Control Service" dir=in action=allow program="%TVProgramFiles%\TeamViewer_Service.exe" edge=yes
    
    REM When uninstalling, TV schedules removal of leftover files from its dir. When resinstalling, it does not remove this pending move command, so it stops working after next reboot.
    REM to avoid that, copy these files and schedule their move to normal location.
    REG ADD "HKEY_CURRENT_USER\Software\Sysinternals\Movefile" /v "EulaAccepted" /t REG_DWORD /d 1 /f
    IF NOT DEFINED movefileexe CALL :findexe movefileexe movefile.exe
    IF NOT DEFINED xlnexe CALL :findexe xlnexe xln.exe
    IF NOT DEFINED movefileexe GOTO :skipNormalizingTV
    IF NOT DEFINED xlnexe SET "xlnexe=xln.exe"
)
(
    PUSHD "%TVProgramFiles%" || GOTO :skipNormalizingTV
	FOR %%I IN (*.dll *.exe) DO (
	    %xlnexe% "%%~I" "%%~I.copy" || COPY /B "%%~I" "%%~I.copy"
	    %movefileexe% /nobanner "%%~I.copy" "%%~I"
	)
    POPD
)
    :skipNormalizingTV
(    
    REM Hiding Desktop Shortcut
    SET RegQueryParsingOptions="usebackq tokens=3* delims= "
    FOR /F "usebackq delims=" %%I IN (`ver`) DO SET "WinVer=%%I"
)
(
    IF "%WinVer:~0,24%"=="Microsoft Windows 2000 [" GOTO :IncludeRecoding
    IF "%WinVer:~0,22%"=="Microsoft Windows XP [" GOTO :IncludeRecoding
    GOTO :SkipRecoding
)
    :IncludeRecoding
(
    rem     there's tab in end of next line. It's mandatory
    SET RegQueryParsingOptions="usebackq tokens=2* delims=	"
    IF NOT DEFINED recodeexe CALL :findexe recodeexe recode.exe %SystemDrive%\SysUtils\UnxUtils\recode.exe
)
    IF DEFINED recodeexe SET "recodecmd=^^^|%recodeexe% -f --sequence=memory 1251..866"
    :SkipRecoding
(
    FOR /F %RegQueryParsingOptions% %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Common Desktop" %recodecmd%`) DO SET "CommonDesktop=%%J"
    IF NOT DEFINED CommonDesktop EXIT /B
)
    FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO %CommonDesktop%`) DO SET "CommonDesktop=%%I"
(
    ATTRIB +H "%CommonDesktop%\TeamViewer*.lnk"
    
    START "Starting TeamViewer5 Service" /MIN %comspec% /C "%SystemRoot%\System32\ping.exe 127.0.0.1 -n 15 >NUL & %SystemRoot%\System32\net.exe start TeamViewer5"
    IF DEFINED debug PAUSE
EXIT /B
)
:arg_CleanupBeforeReinstall
(
    IF EXIST "%lProgramFiles%\Teamviewer\Version5\install.exe"			"%lProgramFiles%\Teamviewer\Version5\install.exe" -remove TEAMVIEWERVPN
    IF EXIST "%lProgramFiles%\Teamviewer\Version5\TeamViewer_Service.exe"	"%lProgramFiles%\Teamviewer\Version5\TeamViewer_Service.exe" -uninstall
    %SystemRoot%\System32\ping.exe 127.0.0.1 -n 5 >NUL
    %SystemRoot%\System32\taskkill.exe /F /IM TeamViewer_Service.exe
    %SystemRoot%\System32\taskkill.exe /F /IM TeamViewer.exe
    IF EXIST "%lProgramFiles%\Teamviewer\Version5" RD /S /Q "%lProgramFiles%\Teamviewer\Version5"
    IF EXIST "%lProgramFiles%\Teamviewer\Version5" MOVE /Y "%lProgramFiles%\Teamviewer\Version5" "%lProgramFiles%\Teamviewer\Version5_bak%RANDOM%"
    IF DEFINED debug PAUSE
EXIT /B
)
:FindSoftwareSource
    CALL :CheckSetSoftSource "%~d0\Distributives\Soft" || CALL :CheckSetSoftSource "%~dp0..\..\Soft" ( || CALL :CheckSetSoftSource "%~d0\Soft" || CALL :CheckSetSoftSource "\\Srv0\Distributives\Soft" || CALL :CheckSetSoftSource "\\Srv0.office0.mobilmir\Distributives\Soft" || EXIT /B 1
(
    SET "utilsdir=%SoftSourceDir%PreInstalled\utils\"
EXIT /B
)
:CheckSetSoftSource
(
    IF EXIST "%~1" (
	SET "SoftSourceDir=%~f1\"
	ECHO SoftSourceDir: %SoftSourceDir%
	EXIT /B 0
    )
EXIT /B 
)
:FindAutohotkeyExe
    FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
(
    IF DEFINED AutohotkeyExe IF EXIST %AutohotkeyExe% EXIT /B 0
    SET "findExeTestExecutionOptions=/ErrorStdOut ."
    CALL :findexe AutohotkeyExe "%ProgramFiles%\AutoHotkey\AutoHotkey.exe" "%ProgramFiles(x86)%\AutoHotkey\AutoHotkey.exe"
    SET "findExeTestExecutionOptions="
EXIT /B
)
:GetFirstArg
(
    SET "%1=%2"
EXIT /B
)
:find7zexe
(
    FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command" /ve`) DO CALL :checkDirFrom1stArg %%B && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CURRENT_USER\Software\7-Zip" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\7-Zip" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString"`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString" /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B

    CALL :findexe exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL :findexe exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" || (ECHO  & EXIT /B 9009)

EXIT /B
)
:checkDirFrom1stArg <arg1> <anything else>
(
    CALL :Check7zDir "%~dp1"
EXIT /B
)
:Check7zDir <dir>
    IF NOT "%~1"=="" SET "dir7z=%~1"
    IF "%dir7z:~-1%"=="\" SET "dir7z=%dir7z:~0,-1%"
(
    IF NOT EXIST "%dir7z%\7z.exe" EXIT /B 9009
    "%dir7z%\7z.exe" <NUL >NUL 2>&1 || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
    SET exe7z="%dir7z%\7z.exe"
EXIT /B
)
:findexe
    (
    SET "locvar=%~1"
    SET "seekforexecfname=%~nx2"
    )
    (
    FOR /D %%I IN ("%~dp2") DO IF EXIST "%%~I%seekforexecfname%" CALL :testexe %locvar% "%%~I%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% %2 & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED srcpath CALL :testexe %locvar% "%srcpath%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED utilsdir CALL :testexe %locvar% "%utilsdir%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    FOR /R "%SystemDrive%\SysUtils" %%I IN (.) DO IF EXIST "%%~I\%seekforexecfname%" CALL :testexe %locvar% "%%~I\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "%srcpath%..\..\..\..\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\localhost\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
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
	"%~2" %findExeTestExecutionOptions% <NUL >NUL 2>&1
	IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
	SET %~1="%~2"
EXIT /B
    )
