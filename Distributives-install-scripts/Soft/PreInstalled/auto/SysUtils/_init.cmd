@(REM coding:CP866
REM part of script-set to install preinstalled and working-without-install software
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
IF NOT DEFINED ErrorCmd (
    SET "ErrorCmd=SET ErrorPresence=1"
    SET "ErrorPresence=0"
)
SET "SysUtilsDir=%SystemDrive%\SysUtils"
)
(
IF NOT DEFINED utilsdir SET "utilsdir=%srcpath%..\..\utils\"
SET "pathString=%ProgramData%\mobilmir.ru;%ProgramData%\mobilmir.ru\Common_Scripts;%SysUtilsDir%\libs;%SysUtilsDir%;%SysUtilsDir%\libs\GTK+\lib;%SysUtilsDir%\libs\OpenSSL\bin;%SysUtilsDir%\libs\OpenSSL;%SysUtilsDir%\SysInternals;%SysUtilsDir%\gnupg;%SysUtilsDir%\ResKit;%SysUtilsDir%\Support Tools;%SysUtilsDir%\UnxUtils;%SysUtilsDir%\UnxUtils\Uri;%SysUtilsDir%\UnxUtils\lbrisar;%SysUtilsDir%\kliu;%SysUtilsDir%\gnupg\pub"
EXIT /B
)
