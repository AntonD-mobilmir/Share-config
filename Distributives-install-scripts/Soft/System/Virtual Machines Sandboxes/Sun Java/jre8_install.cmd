@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

rem Distmask
SET "distmask=jre-8*-windows-i586.exe"

ECHO. >>"%TEMP%\jre_install.flag"

SET "ProgramFilesx86=%ProgramFiles%"
IF DEFINED ProgramFiles^(x86^) SET "ProgramFilesx86=%ProgramFiles(x86)%"

SET JREInstallLogParm=
IF DEFINED JREInstallLog SET JREInstallLogParm=/L "%JREInstallLog%"

SET reg="%SYSTEMROOT%\System32\REG.EXE"
REM installing 32-bit JRE. So, if we're on 64-bit windows, must use 32-bit REG.EXE
IF EXIST "%SYSTEMROOT%\SysWOW64\REG.EXE" SET reg="%SYSTEMROOT%\SysWOW64\REG.EXE"

CALL :InitRemembering
)
FOR /R "%~dp0" %%I IN ("%distmask%") DO CALL :RememberIfLatest dstfname "%%~fI"
(
IF NOT DEFINED dstfname EXIT /B -1
COPY /Y "%~dpn0.cfg" "%TEMP%\%~n0.cfg"
CALL :runmsiexec "%dstfname%" INSTALLCFG="%TEMP%\%~n0.cfg" %JREInstallLogParm%
)
(
rem SET "InstallError=%ERRORLEVEL%" -- EXIT is in same subsection

REM uninstall previous versions
IF NOT ERRORLEVEL 1 CALL "%~dp0jre8_uninstall.cmd" /LeaveLast

rem %REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Plug-in\1.6.0_12" /v HideSystemTrayIcon /t REG_DWORD /d 1 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableJavaUpdate /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableAutoUpdateCheck /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyDownload /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyInstall /t REG_DWORD /d 0 /f
%REG% DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v SunJavaUpdateSched /f

REM Uninstall updater
IF NOT ERRORLEVEL 1 CALL :runmsiexec "%SystemRoot%\System32\msiexec.exe" /x "{4A03706F-666A-4037-7777-5F2748764D10}" /qn

REM Uninstall quickstart
FOR /D %%I IN ("%ProgramFilesx86%\Java\jre*") DO "%%~I\bin\jqs.exe" -unregister

CALL "%~dp0HideStartMenuIcons.cmd"
rem EXIT /B %InstallError% -- SET is in same subsection
EXIT /B %ERRORLEVEL%
)

:runmsiexec
(
%*
IF ERRORLEVEL 1618 IF NOT ERRORLEVEL 1619 ( PING 127.0.0.1 -n 30 >NUL & GOTO :runmsiexec ) & rem another install in progress, wait and retry
IF ERRORLEVEL 3010 IF NOT ERRORLEVEL 3011 EXIT /B 0 & rem restart required
EXIT /B
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
