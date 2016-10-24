@REM coding:OEM

REM ahk script works better
del_old_tempfiles.ahk %*
EXIT /B

REM Remove old files from %TEMP%
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
REM This script is licensed under LGPL
SET UnxUt=%SystemDrive%\SysUtils\UnxUtils\

PUSHD "%TEMP%"||EXIT /B
    attrib -R *.* /S /D
    "%UnxUt%find.exe" . -mindepth 1 -atime +7 -type f -or -ctime +31 -type f -exec %comspec% /C DEL /F """{}""" ;
    "%UnxUt%find.exe" . -type d -mindepth 1 -exec %comspec% /C RD """{}""" ;
POPD

EXIT /B
