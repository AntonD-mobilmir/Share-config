@REM coding:CP866
REM part of script-set to install preinstalled and working-without-install software
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
REM 
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED utilsdir SET utilsdir=%srcpath%..\utils\

SET SysUtilsDir=%SystemDrive%\SysUtils
IF NOT DEFINED ProgramData SET ProgramData=%ALLUSERSPROFILE%\Application Data
SET pathString=%ProgramData%\mobilmir.ru;%ProgramData%\mobilmir.ru\Common_Scripts;%SysUtilsDir%\libs;%SysUtilsDir%;%SysUtilsDir%\libs\GTK+\lib;%SysUtilsDir%\libs\OpenSSL\bin;%SysUtilsDir%\libs\OpenSSL;%SysUtilsDir%\SysInternals;%SysUtilsDir%\gnupg;%SysUtilsDir%\ResKit;%SysUtilsDir%\Support Tools;%SysUtilsDir%\UnxUtils;%SysUtilsDir%\UnxUtils\Uri;%SysUtilsDir%\UnxUtils\lbrisar;%SysUtilsDir%\Piriform;%SysUtilsDir%\uwe-sieber.de;%SysUtilsDir%\kliu;%SysUtilsDir%\gnupg\pub;
PATH %PATH%;%pathString%
"%utilsdir%pathman.exe" /as "%pathString%"
