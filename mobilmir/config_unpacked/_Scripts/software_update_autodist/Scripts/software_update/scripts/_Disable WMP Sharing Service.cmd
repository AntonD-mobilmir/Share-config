@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

rem Disable Windows Media Player network sharing service
sc config "WMPNetworkSvc" start= disabled
sc stop "WMPNetworkSvc"
