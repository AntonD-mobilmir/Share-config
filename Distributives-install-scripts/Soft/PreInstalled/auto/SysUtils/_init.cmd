@(REM coding:CP866
REM part of script-set to install preinstalled and working-without-install software
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED ErrorCmd (
        SET "ErrorCmd=SET ErrorPresence=1"
        SET "ErrorPresence="
    )
    SET "SysUtilsDir=%SystemDrive%\SysUtils"
    SET "utilsdir=%~dp0..\..\utils\"
    
    SET "OS64Bit="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"
    
    IF NOT DEFINED exename7za IF DEFINED OS64Bit ( SET "exename7za=7za64.exe" ) ELSE ( SET "exename7za=7za.exe" )
    IF NOT DEFINED exenameAutohotkey IF DEFINED OS64Bit ( SET "exenameAutohotkey=AutoHotkeyU64.exe" ) ELSE ( SET "exenameAutohotkey=AutoHotkey.exe" )
)
(
    IF NOT DEFINED exe7z SET exe7z="%utilsdir%%exename7za%"
    IF NOT DEFINED AutohotkeyExe SET AutohotkeyExe="%utilsdir%%exenameAutohotkey%"
    SET "pathString=%ProgramData%\mobilmir.ru;%ProgramData%\mobilmir.ru\Common_Scripts;%SysUtilsDir%\libs;%SysUtilsDir%;%SysUtilsDir%\libs\GTK+\lib;%SysUtilsDir%\libs\OpenSSL\bin;%SysUtilsDir%\libs\OpenSSL;%SysUtilsDir%\SysInternals;%SysUtilsDir%\gnupg;%SysUtilsDir%\ResKit;%SysUtilsDir%\Support Tools;%SysUtilsDir%\UnxUtils;%SysUtilsDir%\UnxUtils\Uri;%SysUtilsDir%\UnxUtils\lbrisar;%SysUtilsDir%\kliu;%SysUtilsDir%\gnupg"
    EXIT /B
)
