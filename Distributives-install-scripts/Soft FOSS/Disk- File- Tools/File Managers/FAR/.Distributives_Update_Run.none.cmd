@REM coding:OEM
SET srcpath=%~dp0
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://www.farmanager.com/download.php *.7z -ml1 -A.7z -nd

SET srcpath=%srcpath%x64\
CALL "%baseScripts%\_DistDownload.cmd" - -i..\x64.url *.7z -ml1 -A.7z -nd
