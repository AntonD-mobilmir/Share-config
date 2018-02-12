@(REM coding:CP866
FOR %%A IN ("%~dp0*.dll" "%~dp0*.ocx") DO IF /I "%%~nxA" NEQ "Shop2EL.dll" %SystemRoot%\System32\regsvr32.exe /s "%%~A" || CALL :EchoError "%%~A"

%SystemRoot%\System32\ping.exe -n 5 127.0.0.1 >NUL
%SystemRoot%\System32\regsvr32.exe /s "%~dp0Shop2EL.dll"
EXIT /B
)
:EchoError
(
ECHO Error %ERRORLEVEL% registering %1
EXIT /B
)
