@REM coding:CP866

IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

IF EXIST "%~dp0..\..\..\..\Updates\Windows\wsusoffline\msse\x64-glb\MSEInstall-x64-rus.exe" (
    %SystemDrive%\SysUtils\xln.exe "%~dp0..\..\..\..\Updates\Windows\wsusoffline\msse\x64-glb\MSEInstall-x64-rus.exe" "%~dp0mseinstall.exe"
) ELSE CALL \Scripts\_DistDownload.cmd http://mse.dlservice.microsoft.com/download/7/6/0/760B9188-4468-4FAD-909E-4D16FE49AF47/ruRU/amd64/mseinstall.exe

rem http://www.microsoft.com/security/portal/definitions/adl.aspx
rem START "" /D"%srcpath%" /B /WAIT wget -N "http://go.microsoft.com/fwlink/?LinkID=121721&arch=x64"
