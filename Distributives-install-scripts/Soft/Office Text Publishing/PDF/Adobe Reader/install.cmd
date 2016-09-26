@REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET utilsdir=%srcpath%..\..\..\PreInstalled\utils\

SET InstSource=%srcpath%AdbeRdr*.*
IF EXIST "%srcpath%AdbeRdr*.msi" SET InstSource=%srcpath%AdbeRdr*.msi
SET MSITransformArchive=%srcpath%transform.7z
SET MSITransformFile=AdbeRdr.mst

FOR %%I IN ("%InstSource%") DO SET InstSource=%%~I

IF "%InstSource%"=="" EXIT /B 2
SET TempDir=%TEMP%\Adobe Reader
MKDIR "%TempDir%"
PUSHD "%TempDir%"||EXIT /B
    CALL :checkunpack "%InstSource%" 
    IF ERRORLEVEL 1 (
	CALL :unpack "%InstSource%"
	FOR %%I IN (*.MSI) DO SET InstSource=%%~I
    )
    CALL :unpack "%MSITransformArchive%"
    IF NOT DEFINED logmsi CALL :GetLogName logmsi "%InstSource%"
:retrymsiexec
    %SystemRoot%\System32\msiexec.exe /i "%InstSource%" /t"%MSITransformFile%" /qn /norestart /l+* "%logmsi%"
    IF ERRORLEVEL 1618 IF NOT ERRORLEVEL 1619 ( PING 127.0.0.1 -n 30 >NUL & GOTO :retrymsiexec ) & rem another install in progress, wait and retry
POPD

CALL "%srcpath%install_updates.cmd"

rem --- inside install_updates.cmd --- CALL "%~dp0RemoveUnneededAutorunAndServices.cmd"
RD /S /Q "%TempDir%"

EXIT /B

:GetLogName
    SET %1=%TEMP%\%~n2.log
EXIT /B

:checkunpack
    IF "%~x1"==".msi" EXIT /B 0
EXIT /B 1

:unpack
IF /I "%~x1" EQU ".exe" GOTO :unpack.exe
SET exe7z="%srcpath%..\..\..\PreInstalled\utils\7za.exe"
%exe7z% x -aoa -- %1
EXIT /B
:unpack.exe
%1 -nos_ne -nos_o.
EXIT /B
