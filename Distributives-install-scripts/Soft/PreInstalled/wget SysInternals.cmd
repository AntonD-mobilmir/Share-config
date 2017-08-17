@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

PUSHD c:\SysUtils\SysInternals\pstools-eulaed && (
    FOR %%I IN (*.*) DO wget -N live.sysinternals.com/%%~nxI
    POPD
)

PUSHD c:\SysUtils\SysInternals && (
    FOR %%I IN (*.*) DO IF NOT EXIST "pstools-eulaed\%%~nxI" wget -N https://live.sysinternals.com/%%~nxI
    POPD
)
