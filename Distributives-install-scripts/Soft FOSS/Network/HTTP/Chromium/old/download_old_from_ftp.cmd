@REM coding:OEM
SET srcpath=%~dp0
SET BaseURL=http://build.chromium.org/f/chromium/snapshots/Win_Webkit_Latest/
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
FOR /F "usebackq delims=" %%I IN (`wget -q -N -O- %BaseURL%LATEST`) DO CALL "%baseScripts%\_DistDownload.cmd" %BaseURL%%%I/mini_installer.exe mini_installer.exe -N
