@(REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

    SET "distcleanup=1"
    SET "AddtoSUScripts=1"

    IF NOT DEFINED baseScripts SET "baseScripts=\Scripts"
    CALL :Download7zip "%~dp032-bit" *.exe
    CALL :Download7zip "%~dp064-bit" *-x64.exe
EXIT /B
)
:Download7zip <dir> <mask>
(
    SETLOCAL
	IF NOT EXIST %1 MKDIR %1
	SET "srcpath=%~f1\"
	CALL "%baseScripts%\_GetWorkPaths.cmd"
	rem srcpath with baseDistUpdateScripts replaced to baseDistributives
	rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
	rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
	rem logsDir - baseLogsDir with relpath (or nothing)
	IF NOT DEFINED logsDir SET "logsDir=%workdir%"
	CALL "%baseScripts%\_DistDownload.cmd" http://www.7-zip.org/ %2 -ml1 -nd -A.exe
    ENDLOCAL
EXIT /B
)
