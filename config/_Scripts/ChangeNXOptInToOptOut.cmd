@REM coding:OEM
IF NOT EXIST "%SystemDrive%\BOOT.INI" EXIT /B 1
IF NOT DEFINED sedexe CALL "%~dp0findsedexe.cmd" || EXIT /B

%sedexe% "s#/NoExecute=OptIn#/NoExecute=OptOut#ig" %SystemDrive%\BOOT.INI >%SystemDrive%\BOOT.NEW.INI || EXIT /B
ATTRIB -R -H -S %SystemDrive%\BOOT.INI || EXIT /B
COPY /Y %SystemDrive%\BOOT.INI %SystemDrive%\BOOT.BAK || EXIT /B
MOVE /Y %SystemDrive%\BOOT.NEW.INI %SystemDrive%\BOOT.INI
ATTRIB +R +S +H %SystemDrive%\BOOT.INI
