@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

CALL \Scripts\_DistDownload_sf.cmd mpc-hc README.txt
CALL \Scripts\_DistDownload_sf.cmd mpc-hc MPC-HC.*.x86.exe
CALL \Scripts\_DistDownload_sf.cmd mpc-hc MPC-HC.*.x86.7z
CALL \Scripts\_DistDownload_sf.cmd mpc-hc MPC-HC.*.x64.exe
CALL \Scripts\_DistDownload_sf.cmd mpc-hc MPC-HC.*.x64.7z
