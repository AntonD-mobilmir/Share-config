@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS

    SET "distcleanup=1"
    SET "AddtoS_UScripts=1"

    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "UpdateScriptName=7Zip"
    CALL :Download7zip "%~dp032-bit" *.exe
    CALL :Download7zip "%~dp064-bit" *-x64.exe
EXIT /B
)
:Download7zip <dir> <mask>
(
    SETLOCAL
	IF NOT EXIST %1 MKDIR %1
	SET "srcpath=%~f1\"
	CALL "%baseScripts%\_DistDownload.cmd" http://www.7-zip.org/ %2 -ml1 -nd -A.exe
    ENDLOCAL
EXIT /B
)
