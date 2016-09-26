@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

SET FVIInstOpt=%FVIInstOpt% /bmp=1 /gif=1 /jpg=1 /tif=1 /png=1 /pcx=1 /emf=1
SET DistributiveMask=FreeVimager-*-Setup-Rus.exe
FOR /F "usebackq delims=" %%I IN (`%SystemDrive%\SysUtils\UnxUtils\find "%srcpath:~,-1%" -name "%DistributiveMask%"`) DO (
    SET "Distributive=%%~I"
)
IF NOT DEFINED Distributive FOR %%I IN ("%srcpath%%DistributiveMask%") DO (
    SET Distributive=%%~I
    GOTO :found
)
IF NOT DEFINED Distributive (
    ECHO Distributive not found!
    EXIT /B 1
)
:found
(
"%Distributive%" /S %FVIInstOpt%
CALL :FindFVIDir EXIT /B
)
(
rem done by installer: REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Contaware\FreeVimager" /v "Install_Dir" /d "%FVIdir%" /f
    REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\FreeVimager.exe" /ve /d "%FVIdir%\FreeVimager.exe" /f
    REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\fvi" /ve /d "%FVIdir%\FreeVimager.exe" /f
EXIT /B
)
:FindFVIDir
(
    SET "lProgramFiles=%ProgramFiles%"
    IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"
)
    FOR /D %%I IN ("%lProgramFiles%\FreeVimager*") DO IF EXIST "%%~I\FreeVimager.exe" (
	SET "FVIdir=%%~I"
	EXIT /B 0
    )
EXIT /B 1
