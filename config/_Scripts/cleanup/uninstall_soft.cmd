@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
rem SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED PROGRAMDATA (
	REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "ProgramData" /t REG_EXPAND_SZ /d "%%ALLUSERSPROFILE%%\Application Data" /f
	SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    )
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    CALL "%~dp0..\FindSoftwareSource.cmd"
    CALL "%~dp0..\FindAutoHotkeyExe.cmd"
    
    SET "lProgramFiles=%ProgramFiles%" & IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"
    SET "SysNative=%SystemRoot%\System32" & IF EXIST "%SystemRoot%\SysNative\cmd.exe" SET "SysNative=%SystemRoot%\SysNative"
    SET "SysWOW64=%SystemRoot%\System32" & IF EXIST "%SystemRoot%\SysWOW64\cmd.exe" SET "SysWOW64=%SystemRoot%\SysWOW64"

    ECHO Running uninstall scripts...

    FOR /F "usebackq delims=" %%A IN (`DIR /O /B "%~dp0uninstall\*.cmd" "%~dp0uninstall\*.ahk"`) DO (
	SET "RunningUninstallName=%%~nA"
	IF /I "%%~xA"==".cmd" (
	    CALL "%~dp0uninstall\%%~A"
	) ELSE IF /I "%%~xA"==".ahk" (
	    %AutohotkeyExe% /ErrorStdOut "%~dp0uninstall\%%~A"
	)
    )
)
