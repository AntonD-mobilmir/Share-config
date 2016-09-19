REM coding:OEM
IF NOT "%~1"=="" (
    SET TGT=\\%~1\
    SC \\%1 START RemoteRegistry
)
REG ADD "%TGT%HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d 1 /f
