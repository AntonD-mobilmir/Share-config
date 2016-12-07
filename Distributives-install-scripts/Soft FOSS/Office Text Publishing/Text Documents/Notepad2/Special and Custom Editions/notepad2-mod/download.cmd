@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET distcleanup=1
rem SET findargs=-name *.exe -or -name *.7z
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://xhmikosr.github.io/notepad2-mod/ Notepad2-mod*.exe -ml 1 -nd --no-check-certificate "--restrict-file-names=windows" "-e robots=off" -HD github.com
rem https://github.com/XhmikosR/notepad2-mod/releases/download/4.2.25.870/Notepad2-mod.4.2.25.870.exe
