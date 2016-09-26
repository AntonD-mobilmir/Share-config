(
@REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
FOR /F "usebackq tokens=1 delims=]" %%I IN (`find /n "-!!! extensions list-" "%~0"`) DO SET skiplines=%%I
)
(
REM next line gets from 2nd character to the EOL
SET skiplines=%skiplines:~1%

IF NOT DEFINED dest7zinst CALL "%~dp0Find7zDir.cmd" || EXIT /B
)
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Applications\7zFM.exe\shell\Open\Command" /ve /t REG_EXPAND_SZ /d "\"%dest7zinst%\7zFM.exe\" \"%%1\"" /f /reg:64
FOR /F "usebackq skip=%skiplines% tokens=*" %%I IN ("%~0") DO (
  IF "%%I"=="" GOTO :exitfor
  CALL :registerExtension %%I
)
:exitfor
EXIT /B
:registerExtension <.ext>
(
    ASSOC %1=7-Zip%1
    FTYPE 7-Zip%1="%dest7zinst%\7zFM.exe" "%%1"
    EXIT /B
)

REM List of extensions to associate follows.
REM empty line is endlist-marker
REM 
REM -!!! extensions list- this is marker
.001
.7z
.7zip
.arj
.bz2
.bzip2
.cab
.cpio
.deb
.dmg
.fat
.gz
.gzip
.hfs
.lha
.lzh
.lzma
.ntfs
.rar
.rpm
.swm
.tar
.taz
.tbz
.tbz2
.tgz
.tpz
.txz
.vhd
.wim
.xar
.xz
.z
.zip

