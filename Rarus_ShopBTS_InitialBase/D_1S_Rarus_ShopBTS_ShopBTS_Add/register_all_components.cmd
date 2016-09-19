@ECHO OFF
FOR %%i IN ("%~dp0*.dll") DO IF /I "%%~nxi" NEQ "Shop2EL.dll" regsvr32.exe /s "%%i"
FOR %%i IN ("%~dp0*.ocx") DO regsvr32.exe /s "%%i"

PING 127.0.0.1 -n 5 >NUL
regsvr32 /s "%~dp0Shop2EL.dll"
