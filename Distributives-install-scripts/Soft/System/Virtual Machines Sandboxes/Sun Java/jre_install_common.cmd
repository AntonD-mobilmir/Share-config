@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
    ECHO. >>"%TEMP%\jre_install.flag"

    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"

    SET "ProgramFilesx86=%ProgramFiles%"
    IF DEFINED ProgramFiles^(x86^) SET "ProgramFilesx86=%ProgramFiles(x86)%"
    IF DEFINED JREInstallLog SET JREInstallLogParm=/L "%JREInstallLog%"

    CALL :InitRemembering
    FOR /R "%~dp0" %%I IN (%*) DO (
	ECHO %%I
	CALL :RememberIfLatest dstfname "%%~fI"
    )
    IF NOT DEFINED dstfname (
	ECHO Distributive for mask %* not found
	EXIT /B 2
    )
)
@(
    ECHO Installing %dstfname%
    COPY /Y "%~dpn0.cfg" "%TEMP%\%~n0.cfg"
    REM msiexec not needed here, since the distributive is exe
    CALL "%~dp0run_msiexec.cmd" "%dstfname%" INSTALLCFG="%TEMP%\%~n0.cfg" %JREInstallLogParm%

    SET regexe="%SYSTEMROOT%\System32\REG.EXE"
    REM if installing 32-bit JRE on 64-bit windows, must use 32-bit REG.EXE
    IF EXIST "%SYSTEMROOT%\SysWOW64\REG.EXE" IF "%dstfname:-i586=%" NEQ "%dstfname%" SET regexe="%SYSTEMROOT%\SysWOW64\REG.EXE"
)
@(
    rem SET "InstallError=%ERRORLEVEL%" -- EXIT is in same subsection

    rem %regexe% ADD "HKLM\SOFTWARE\JavaSoft\Java Plug-in\1.6.0_12" /v HideSystemTrayIcon /t REG_DWORD /d 1 /f
    %regexe% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableJavaUpdate /t REG_DWORD /d 0 /f
    %regexe% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableAutoUpdateCheck /t REG_DWORD /d 0 /f
    %regexe% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyDownload /t REG_DWORD /d 0 /f
    %regexe% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyInstall /t REG_DWORD /d 0 /f

    FOR %%A IN (32 64) DO %regexe% DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SunJavaUpdateSched" /f /reg:%%~A

    REM Uninstall updater
    IF NOT ERRORLEVEL 1 CALL "%~dp0run_msiexec.cmd" "%SystemRoot%\System32\msiexec.exe" /x "{4A03706F-666A-4037-7777-5F2748764D10}" /qn

    REM Uninstall quickstart
    FOR /D %%I IN ("%ProgramFilesx86%\Java\jre*") DO "%%~I\bin\jqs.exe" -unregister
    CALL "%~dp0HideStartMenuIcons.cmd"

    CALL :Compact "%ProgramData%\Oracle\Java"
    rem EXIT /B %InstallError% -- SET is in same subsection
EXIT /B %ERRORLEVEL%
)

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

:Compact
(
    FOR %%O IN ("/EXE:LZX" "") DO ECHO %SystemRoot%\System32\COMPACT.exe /C %%~O /S:"%ProgramData%\Oracle\Java" && EXIT /B
EXIT /B
)
