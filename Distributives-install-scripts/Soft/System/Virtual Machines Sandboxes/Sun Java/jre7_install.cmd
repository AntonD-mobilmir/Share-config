@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

IF "%~1"=="" GOTO :SkipArg
SET Arg=%1
IF "%Arg:~,1%"=="/" GOTO :%Arg:~1%
:SkipArg

ECHO. >>"%TEMP%\jre_install.flag"
SET distmask=jre-7*-windows-i586.exe

CALL :InitRemembering
FOR /R "%~dp0" %%I IN ("%distmask%") DO CALL :RememberIfLatest dstfname "%%~fI"

SET JREInstallLogParm=
IF DEFINED JREInstallLog SET JREInstallLogParm=/L %JREInstallLog%

CALL :FindAutoHotkeyExe || SET AutohotkeyExe=
START "" %AutohotkeyExe% "%~dp0wait and close cert warning.ahk"
SET InstallError=0
"%dstfname%" /s REBOOT=Suppress SPONSORS=0 DISABLEAD=1 %JREInstallLogParm%||SET InstallError=1
rem ADDLOCAL=ALL IEXPLORER=1 MOZILLA=1 JAVAUPDATE=0 AUTOUPDATECHECK=0 

:SettingsOnly
DEL "%TEMP%\jre_install.flag"

CALL "%~dp0HideStartMenuIcons.cmd"

msiexec.exe /x {4A03706F-666A-4037-7777-5F2748764D10} /qn

SET reg=REG.exe
IF EXIST "%SYSTEMROOT%\SysWOW64\REG.EXE" SET REG="%SYSTEMROOT%\SysWOW64\REG.EXE"

rem %REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Plug-in\1.6.0_12" /v HideSystemTrayIcon /t REG_DWORD /d 1 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableJavaUpdate /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableAutoUpdateCheck /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyDownload /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyInstall /t REG_DWORD /d 0 /f
%REG% DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v SunJavaUpdateSched /f

SET ProgramFilesx86=%ProgramFiles%
IF DEFINED ProgramFiles^(x86^) SET "ProgramFilesx86=%ProgramFiles(x86)%"
"%ProgramFilesx86%\Java\jre7\bin\jqs" -unregister

EXIT /B %InstallError%

:InitRemembering
(
    SET "LatestDate=0000000000:00"
EXIT /B
)

:RememberIfLatest
(
    SET "CurrentDate=%~t2"
)
(
@rem     01.12.2011 21:29, so reverse date to get correct comparison
    SET "CurrentDate=%CurrentDate:~6,4%%CurrentDate:~3,2%%CurrentDate:~0,2%%CurrentDate:~11%"
)
    IF "%CurrentDate%" GEQ "%LatestDate%" (
	SET "%~1=%~2"
	SET "LatestDate=%CurrentDate%"
    )
EXIT /B

:FindAutoHotkeyExe
    FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
    GOTO :SkipGetFirstArg
    :GetFirstArg
	SET %1=%2
    EXIT /B
    :SkipGetFirstArg

    IF DEFINED AutohotkeyExe IF EXIST %AutohotkeyExe% EXIT /B 0

    SET AutohotkeyExe="%~dp0..\..\..\PreInstalled\utils\AutoHotkey.exe"
    IF NOT EXIST %AutohotkeyExe% SET AutohotkeyExe="%ProgramFiles%\AutoHotkey\AutoHotkey.exe"
    IF NOT EXIST %AutohotkeyExe% SET AutohotkeyExe="%ProgramFiles(x86)%\AutoHotkey\AutoHotkey.exe"

    IF NOT EXIST %AutohotkeyExe% EXIT /B 1
EXIT /B
