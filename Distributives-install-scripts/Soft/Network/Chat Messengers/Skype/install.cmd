@REM coding:OEM

SET MSIFileName=SkypeSetup.msi

IF NOT DEFINED logmsi SET logmsi=%TEMP%\%MSIFileName%.log

%SystemRoot%\System32\msiexec.exe /i "%~dp0%MSIFileName%" /qn /norestart /l+* "%logmsi%" TRANSFORMS=:RemoveStartup.mst;:RemoveDesktopShortcut.mst
