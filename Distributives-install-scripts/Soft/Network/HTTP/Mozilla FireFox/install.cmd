@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    SET "distSubdir=32-bit\"
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "distSubdir=64-bit\"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "distSubdir=64-bit\"
    IF DEFINED ProgramW6432 ( SET "lProgramFiles=%ProgramW6432%" ) ELSE SET "lProgramFiles=%ProgramFiles%"
    SET "ErrorMemory="

    SET "TempIni=%TEMP%\FirefoxInstall.ini"
    FOR /F "usebackq delims=" %%I IN (`ver`) DO SET "winVer=%%~I"
    CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
)
(
    IF DEFINED DefaultsSource CALL :GetDir configDir "%DefaultsSource%"
    IF "%winVer:~0,30%"=="Microsoft Windows [Версия 6.0." SET "winVista=1"
    IF "%winVer:~0,31%"=="Microsoft Windows [Version 6.0." SET "winVista=1"
    IF DEFINED winVista (
	IF EXIST "%srcpath%Vista\Firefox Setup *.exe" (
	    SET "InstDistributive=%srcpath%Vista\Firefox Setup *.exe"
	) ELSE SET "InstDistributive=%srcpath:\Distributives\Soft\=\Distributives\Soft_old\%Vista\Firefox Setup *.exe"
    ) ELSE SET "InstDistributive=%srcpath%%distSubdir%Firefox Setup *.exe"
    SET "MozMainSvcUninst=%lProgramFiles%\Mozilla Maintenance Service\Uninstall.exe"
    SET "cProgramFiles=%lProgramFiles:\=\\%"
)
(
    FOR %%A IN ("%InstDistributive%") DO SET "InstDistributive=%%~A"
    COPY /B /Y "%srcpath%install.ini" "%TempIni%"

    IF DEFINED configDir SET "pathAppendSubpath=libs" & CALL "%configDir%_Scripts\find_exe.cmd" sedexe "%SystemDrive%\SysUtils\sed.exe"
)
(
    IF DEFINED sedexe %sedexe% "s/;InstallDirectoryPath={InstallDirectoryPath}/InstallDirectoryPath=%cProgramFiles%\\Mozilla Firefox/" "%srcpath%install.ini">"%TempIni%"
    "%InstDistributive%" /S /INI="%TempIni%" || CALL :SetErrorMemory

    REM Copying defaults and fixed
    IF EXIST "%DefaultsSource%" CALL :UnpackDefaults
    IF EXIST "%MozMainSvcUninst%" "%MozMainSvcUninst%" /S

    CALL :HideDesktopShortcut
    IF NOT DEFINED ErrorMemory EXIT /B 0
)
EXIT /B %ErrorMemory%

:UnpackDefaults
IF NOT DEFINED exe7z CALL "%configDir%_Scripts\find7zexe.cmd" || EXIT /B
(
    %exe7z% x -aoa -y -r0 -o"%lProgramFiles%\" -- "%DefaultsSource%" "Mozilla Firefox\"
EXIT /B
)
:HideDesktopShortcut
    REM Hiding desktop shortcut
    SET RegQueryParsingOptions="usebackq tokens=3* delims= "
(
    FOR /F %RegQueryParsingOptions% %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Common Desktop" %recodecmd%`) DO SET "CommonDesktop=%%~J"
    IF NOT DEFINED CommonDesktop EXIT /B
)
    FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO %CommonDesktop%`) DO SET "CommonDesktop=%%~I"
(
    ATTRIB +H "%CommonDesktop%\Mozilla Firefox.lnk"

EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
:SetErrorMemory
(
    SET "ErrorMemory=%ERRORLEVEL%"
EXIT /B
)
