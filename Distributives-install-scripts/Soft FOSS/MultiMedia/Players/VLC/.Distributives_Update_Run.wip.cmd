@REM coding:OEM
SET srcpath=%~dp0

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://www.videolan.org/vlc/download-windows.html vlc-*-win32.exe -ml2 -A.exe -DH get.videolan.org,www.videolan.org,mirror.yandex.ru
