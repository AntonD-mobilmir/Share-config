@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF NOT DEFINED ProgramData SET "ProgramData=%ALLUSERSPROFILE%\Application Data"

FOR /F "usebackq delims=" %%I IN (`dir /b /o-d "%~dp0foobar2000*.exe"`) DO (
    SET distName=%%~I
    GOTO :ProceedWithInstall
)

REM If here, no distrubitive found
EXIT /B 1
)
:ProceedWithInstall
    "%~dp0%distName%" /S
    SET "InstallErrorLevel=%ERRORLEVEL%"
    CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
    IF DEFINED DefaultsSource CALL :HideDesktopShortcut
EXIT /B %InstallErrorLevel%

:HideDesktopShortcut
(
    CALL :GetDir configDir "%DefaultsSource%"
    REM Hiding desktop shortcut
    FOR /F "usebackq delims=" %%I IN (`ver`) DO SET "WinVer=%%~I"
    IF DEFINED WinVer CALL :CheckRecoding
    SET RegQueryParsingOptions="usebackq tokens=3* delims= "
    GOTO :SkipRecoding
)
:CheckRecoding
    IF "%WinVer:~0,24%"=="Microsoft Windows 2000 [" GOTO :IncludeRecoding
    IF "%WinVer:~0,22%"=="Microsoft Windows XP [" GOTO :IncludeRecoding
:IncludeRecoding
(
    rem     there's tab in end of next line. It's mandatory
    SET RegQueryParsingOptions="usebackq tokens=2* delims=	"
    IF NOT DEFINED recodeexe CALL "%configDir%_Scripts\find_exe.cmd" recodeexe recode.exe %SystemDrive%\SysUtils\UnxUtils\recode.exe
)
    IF DEFINED recodeexe SET recodecmd=^^^|%recodeexe% -f --sequence=memory 1251..866
:SkipRecoding
    FOR /F %RegQueryParsingOptions% %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Common Desktop" %recodecmd%`) DO SET "CommonDesktop=%%~J"
    IF NOT DEFINED CommonDesktop EXIT /B
    FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO %CommonDesktop%`) DO SET "CommonDesktop=%%~I"
    ATTRIB +H "%CommonDesktop%\foobar2000.lnk"

EXIT /B

:GetDir <var> <path>
(
    SET "%~1=%~dp2"
EXIT /B
)
