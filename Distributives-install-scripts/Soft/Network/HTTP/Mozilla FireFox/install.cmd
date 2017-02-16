@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    IF DEFINED ProgramFiles^(x86^) (SET "lProgramFiles=%ProgramFiles(x86)%") ELSE SET "lProgramFiles=%ProgramFiles%"

    SET "TempIni=%TEMP%\FirefoxInstall.ini"
)
(
    SET "InstDistributive=%srcpath%Firefox Setup *.exe"
    SET "MozMainSvcUninst=%lProgramFiles%\Mozilla Maintenance Service\Uninstall.exe"
    SET "cProgramFiles=%lProgramFiles:\=\\%"
    CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
)
IF DEFINED DefaultsSource CALL :GetDir ConfigDir "%DefaultsSource%"
(
    FOR %%A IN ("%InstDistributive%") DO SET "InstDistributive=%%~A"
    COPY /B /Y "%srcpath%install.ini" "%TempIni%"

    IF DEFINED ConfigDir SET "pathAppendSubpath=libs" & CALL "%ConfigDir%_Scripts\find_exe.cmd" sedexe "%SystemDrive%\SysUtils\sed.exe"
    )
)
IF DEFINED sedexe %sedexe% "s/;InstallDirectoryPath={InstallDirectoryPath}/InstallDirectoryPath=%cProgramFiles%\\Mozilla Firefox/" "%srcpath%install.ini">"%TempIni%"
"%InstDistributive%" /S /INI="%TempIni%" || CALL :SetErrorMemory

REM Copying defaults and fixed
IF EXIST "%DefaultsSource%" CALL :UnpackDefaults
IF EXIST "%MozMainSvcUninst%" "%MozMainSvcUninst%" /S

CALL :HideDesktopShortcut
)
EXIT /B %ErrorMemory%

:UnpackDefaults
    CALL "%ConfigDir%_Scripts\find7zexe.cmd" || EXIT /B
(
    %exe7z% x -aoa -r0 -o"%lProgramFiles%\" -- "%DefaultsSource%" "Mozilla Firefox\"
EXIT /B
)
:HideDesktopShortcut
    REM Hiding desktop shortcut
    SET RegQueryParsingOptions="usebackq tokens=3* delims= "
    FOR /F "usebackq delims=" %%I IN (`ver`) DO SET "WinVer=%%~I"
    IF "%WinVer:~0,24%"=="Microsoft Windows 2000 [" GOTO :IncludeRecoding
    IF "%WinVer:~0,22%"=="Microsoft Windows XP [" GOTO :IncludeRecoding
    GOTO :SkipRecoding
:IncludeRecoding
    rem     there's tab in end of next line. It's mandatory
    SET RegQueryParsingOptions="usebackq tokens=2* delims=	"

    IF NOT DEFINED recodeexe CALL :findexe recodeexe recode.exe %SystemDrive%\SysUtils\UnxUtils\recode.exe
    IF DEFINED recodeexe SET "recodecmd=^|%recodeexe% -f --sequence=memory 1251..866"
:SkipRecoding
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
