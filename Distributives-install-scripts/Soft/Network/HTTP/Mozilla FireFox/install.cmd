@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET "lProgramFiles=%ProgramFiles%"
IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"

CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
SET "TempIni=%TEMP%\FirefoxInstall.ini"
)
(
SET "MozMainSvcUninst=%lProgramFiles%\Mozilla Maintenance Service\Uninstall.exe"
SET "InstDistributive=%srcpath%Firefox Setup *.exe"
SET "cProgramFiles=%lProgramFiles:\=\\%"
)
(
FOR %%A IN ("%InstDistributive%") DO SET "InstDistributive=%%~A"
COPY /B /Y "%srcpath%install.ini" "%TempIni%"

CALL :GetDir ConfigDir "%DefaultsSource%"
)
CALL "%ConfigDir%_Scripts\find_exe.cmd" sedexe sed.exe "%SystemDrive%\SysUtils\UnxUtils\sed.exe"
(
IF DEFINED sedexe %sedexe% "s/;InstallDirectoryPath={InstallDirectoryPath}/InstallDirectoryPath=%cProgramFiles%\\Mozilla Firefox/" "%srcpath%install.ini">"%TempIni%"
"%InstDistributive%" /INI="%TempIni%"
)
(
IF ERRORLEVEL 1 SET "ErrorMemory=%ERRORLEVEL%"

REM Copying defaults and fixed
IF EXIST "%DefaultsSource%" CALL :UnpackDefaults
CALL :HideDesktopShortcut

IF EXIST "%MozMainSvcUninst%" "%MozMainSvcUninst%" /S
)
EXIT /B %ErrorMemory%

:UnpackDefaults
    CALL "%ConfigDir%_Scripts\find7zexe.cmd" || EXIT /B
    %exe7z% x -aoa -r0 -o"%lProgramFiles%\" -- "%DefaultsSource%" "Mozilla Firefox\"
EXIT /B

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

    FOR /F %RegQueryParsingOptions% %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Common Desktop" %recodecmd%`) DO SET "CommonDesktop=%%~J"
    IF NOT DEFINED CommonDesktop EXIT /B
    FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO %CommonDesktop%`) DO SET "CommonDesktop=%%~I"

    ATTRIB +H "%CommonDesktop%\Mozilla Firefox.lnk"

EXIT /B

:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
