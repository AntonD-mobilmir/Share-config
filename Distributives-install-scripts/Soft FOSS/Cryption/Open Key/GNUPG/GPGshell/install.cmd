@REM coding:OEM
@ECHO OFF

SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET tempdest=%TEMP%\GPGShell
IF NOT DEFINED ErrorCmd SET ErrorCmd=PAUSE

IF NOT DEFINED exe7z CALL "\\Srv0\profiles$\Share\config\_Scripts\find_exe.cmd" exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL "\\Srv0\profiles$\Share\config\_Scripts\find_exe.cmd" exe7z 7z.exe || EXIT /B
IF NOT DEFINED recodeexe CALL "\\Srv0\profiles$\Share\config\_Scripts\find_exe.cmd" recodeexe recode.exe %SystemDrive%\SysUtils\UnxUtils\recode.exe
IF DEFINED recodeexe SET recodecmd=^^^|%recodeexe% -f --sequence=memory 1251..866

CALL "%srcpath%UserConfig.cmd"

CALL :SetDefaults

FOR %%I IN ("%srcpath%*gpgsh*.zip") DO SET dist=%%~I

%exe7z% x -aoa "%dist%" -o"%tempdest%"||%ErrorCmd%
"%tempdest%\GPGshell-Setup.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-||%ErrorCmd%
RD /S /Q "%tempdest%"||%ErrorCmd%
FOR %%I IN ("%srcpath%GPGshell*.exe") DO "%%~I" /s||%ErrorCmd%

CALL :HideDesktopShortcut

EXIT /B

:SetDefaults
    ECHO Getting ProfilesDirectory, DefaultUserProfile and HKLMStartup
    FOR /F "usebackq tokens=2* delims=	" %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" /v "ProfilesDirectory" %recodecmd%`) DO SET ProfilesDirectory=%%J
    IF NOT DEFINED ProfilesDirectory EXIT /B 1
    FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO %ProfilesDirectory%`) DO SET ProfilesDirectory=%%I

    FOR /F "usebackq tokens=2* delims=	" %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" /v "DefaultUserProfile" %recodecmd%`) DO SET DefaultUserProfile=%%J
    IF NOT DEFINED DefaultUserProfile EXIT /B 1

rem     ECHO backuping of default user profile
rem     IF NOT EXIST "%ProfilesDirectory%\%DefaultUserProfile%.org" XCOPY /E /C /I /Q /H /K /O "%ProfilesDirectory%\%DefaultUserProfile%" "%ProfilesDirectory%\%DefaultUserProfile%.org"

rem     ECHO Overwriting default user profile with "%~dp0Default User\Default User.xp.7z"
rem     %exe7z% x -aoa -o"%ProfilesDirectory%\%DefaultUserProfile%" -- "%~dp0Default User\Default User.xp.7z"

    FOR /F "usebackq tokens=2* delims=	" %%I IN (`REG QUERY "HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Startup" %recodecmd%`) DO SET HKUDStartup=%%J
    IF NOT DEFINED HKUDStartup EXIT /B 1
    SET backupUSERPROFILE=%USERPROFILE%
    SET USERPROFILE=%ProfilesDirectory%\%DefaultUserProfile%
    FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO %HKUDStartup%`) DO SET HKUDStartup=%%I
    SET USERPROFILE=%backupUSERPROFILE%

    COPY /B "%srcpath%UserConfig.cmd" "%HKUDStartup%\GPGshell-UserConfig.cmd"
    ECHO DEL %%0 >>"%HKUDStartup%\GPGshell-UserConfig.cmd"
EXIT /B

:HideDesktopShortcut

    REM Hiding desktop shortcut
    SET RegQueryParsingOptions="usebackq tokens=3* delims= "
    FOR /F "usebackq delims=" %%I IN (`ver`) DO SET WinVer=%%I
    IF "%WinVer:~0,24%"=="Microsoft Windows 2000 [" GOTO :IncludeRecoding
    IF "%WinVer:~0,22%"=="Microsoft Windows XP [" GOTO :IncludeRecoding
    GOTO :SkipRecoding
:IncludeRecoding
    rem     there's tab in end of next line. It's mandatory
    SET RegQueryParsingOptions="usebackq tokens=2* delims=	"

    IF NOT DEFINED recodeexe CALL "\\Srv0\profiles$\Share\config\_Scripts\find_exe.cmd" recodeexe recode.exe %SystemDrive%\SysUtils\UnxUtils\recode.exe
    IF DEFINED recodeexe SET recodecmd=^^^|%recodeexe% -f --sequence=memory 1251..866
:SkipRecoding

    FOR /F %RegQueryParsingOptions% %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Common Desktop" %recodecmd%`) DO SET CommonDesktop=%%J
    IF NOT DEFINED CommonDesktop EXIT /B
    FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO %CommonDesktop%`) DO SET CommonDesktop=%%I

    ATTRIB +H "%CommonDesktop%\GPGkeys.lnk"
:SkipHidingShortcut

EXIT /B
