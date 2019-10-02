@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
    IF NOT DEFINED PROGRAMDATA (
	REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "ProgramData" /t REG_EXPAND_SZ /d "%%ALLUSERSPROFILE%%\Application Data" /f
	SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
    )
    IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    IF DEFINED Distributives IF NOT DEFINED SoftSourceDir SET "Distributives="
    IF NOT DEFINED Distributives CALL "%~dp0..\..\..\FindSoftwareSource.cmd"
    CALL "%~dp0..\..\..\FindAutoHotkeyExe.cmd"
    
    IF DEFINED ProgramFiles^(x86^) ( SET "ProgramFiles32=%ProgramFiles(x86)%" ) ELSE SET "ProgramFiles32=%ProgramFiles%"
    IF DEFINED ProgramW6432 ( SET "ProgramFiles64=%ProgramW6432%" ) ELSE SET "ProgramFiles64=%ProgramFiles%"
    IF EXIST "%SystemRoot%\SysNative\cmd.exe" ( SET "SysNative=%SystemRoot%\SysNative" ) ELSE SET "SysNative=%SystemRoot%\System32"
    IF EXIST "%SystemRoot%\SysWOW64\cmd.exe" ( SET "SysWOW64=%SystemRoot%\SysWOW64" ) ELSE SET "SysWOW64=%SystemRoot%\System32"

    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" ( SET "OSWordSize=64" ) ELSE IF /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" ( SET "OSWordSize=64" ) ELSE SET "OSWordSize=32"
)
