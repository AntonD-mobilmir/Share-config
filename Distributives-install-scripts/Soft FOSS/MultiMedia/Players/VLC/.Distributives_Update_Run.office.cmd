@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS
SET "srcpath=%~dp0"
IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"
)
(
rem CALL "%baseScripts%\_DistDownload.cmd" http://www.videolan.org/vlc/download-windows.html vlc-*-win32.exe -ml2 -A.exe -DH get.videolan.org,www.videolan.org,mirror.yandex.ru
rem -i- --force-html --base=http://
CALL "%baseScripts%\_DistDownload.cmd" http://download.videolan.org/pub/videolan/vlc/last/win64/ "*-win64.7z" -m -np -nd "-A-win64.7z"
FOR /F "usebackq delims=" %%A IN (`wget -q -O- http://www.videolan.org/vlc/download-windows.html ^| grep -P -o "\/\/[^^"">]+?win(32|64)\.(7z|exe)"`) DO CALL :download "http:%%~A"
EXIT /B
)
:download
SET "fname=%~nx1"
(
    CALL "%baseScripts%\_DistDownload.cmd" %1 "*%fname:~-9%"
EXIT /B
)
