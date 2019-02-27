@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload_sf.cmd" mpc-hc README.txt
    CALL "%baseScripts%\_DistDownload_sf.cmd" mpc-hc MPC-HC.*.x86.exe
    CALL "%baseScripts%\_DistDownload_sf.cmd" mpc-hc MPC-HC.*.x86.7z
    CALL "%baseScripts%\_DistDownload_sf.cmd" mpc-hc MPC-HC.*.x64.exe
    CALL "%baseScripts%\_DistDownload_sf.cmd" mpc-hc MPC-HC.*.x64.7z
)
