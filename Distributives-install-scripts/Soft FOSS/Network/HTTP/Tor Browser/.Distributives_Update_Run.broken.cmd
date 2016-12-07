@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
SET "distcleanup=1"
IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"
)
(
rem CALL "%baseScripts%\_DistDownload.cmd" https://www.torproject.org/download/download-easy.html.en *.exe -m -l 1 -HD www.torproject.org,dist.torproject.org "-A .exe,.asc,.en" -nd

CALL "%baseScripts%\_DistDownload.cmd" https://www.torproject.org/download/download-easy.html.en *.exe -m -l 2 -HD dist.torproject.org "-A .exe,.asc,.en" -nd --user-agent="Mozilla/5.0 (Windows NT 5.1; rv:0.0)"
)
