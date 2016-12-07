@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
rem SET findargs=-name *.exe -or -name *.7z

IF NOT DEFINED baseScripts SET baseScripts=\Scripts

REM Поскольку здесь не получится сделать такую shell-маску, чтобы в неё не попал другой exe'шник, distcleanup для этой загрузки = 0
CALL "%baseScripts%\_DistDownload.cmd" https://code.google.com/p/notepad2-mod/downloads/list "Notepad2-mod.*.exe" --no-check-certificate -m -l 2 -e "robots=off" -HD notepad2-mod.googlecode.com

SET distcleanup=1
CALL "%baseScripts%\_DistDownload.cmd" https://code.google.com/p/notepad2-mod/downloads/list "Notepad2-mod.*_x86.zip" --no-check-certificate -m -l 2 -e "robots=off" -HD notepad2-mod.googlecode.com
CALL "%baseScripts%\_DistDownload.cmd" https://code.google.com/p/notepad2-mod/downloads/list "Notepad2-mod.*_x64.zip" --no-check-certificate -m -l 2 -e "robots=off" -HD notepad2-mod.googlecode.com
CALL "%baseScripts%\_DistDownload.cmd" https://code.google.com/p/notepad2-mod/downloads/list "Notepad2-mod.*_ICL12.exe" --no-check-certificate -m -l 2 -e "robots=off" -HD notepad2-mod.googlecode.com
CALL "%baseScripts%\_DistDownload.cmd" https://code.google.com/p/notepad2-mod/downloads/list "Notepad2-mod.*_x86_ICL12.zip" --no-check-certificate -m -l 2 -e "robots=off" -HD notepad2-mod.googlecode.com
CALL "%baseScripts%\_DistDownload.cmd" https://code.google.com/p/notepad2-mod/downloads/list "Notepad2-mod.*_x64_ICL12.zip" --no-check-certificate -m -l 2 -e "robots=off" -HD notepad2-mod.googlecode.com
