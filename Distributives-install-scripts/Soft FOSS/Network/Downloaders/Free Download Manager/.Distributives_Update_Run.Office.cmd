@REM coding:OEM
rem SET AddtoSUScripts=1
CALL "%~dp0download.cmd" %*

PUSHD 5.1-beta && (
    CALL "%~dp05.1-beta\download.cmd"
    POPD
)
