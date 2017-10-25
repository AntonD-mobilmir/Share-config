@REM coding:OEM
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSLicensing\HardwareID" /va /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSLicensing\Store" /va /f
mstsc.exe /V localhost
