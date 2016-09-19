(
@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

SET "tempout=%TEMP%\ASUS PNP0A0A"
SET "reldir=Distributives\Drivers\ASUS\Motherboards\ACPI PNP0A0A"
)
(
SET "srcdir=\\Srv0.office0.mobilmir\%reldir%"
IF NOT EXIST "D:\%reldir%" MKDIR "D:\%reldir%"
IF EXIST "D:\%reldir%" (
    XCOPY "\\Srv0.office0.mobilmir\%reldir%" "D:\%reldir%" /E
    IF NOT ERRORLEVEL 1 SET "srcDir=D:\%reldir%"
)
)
FOR /F "usebackq delims=" %%I IN (`DIR /B /O-D "%srcDir%\*"`) DO (
    SET "srcArc=%srcDir%\%%~I"
    GOTO :foundArc
)
ECHO Не найден архив с драйвером! & PAUSE & EXIT /B

:foundArc
\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\7za.exe x -o"%tempout%" -- "%srcArc%"
PUSHD "%tempout%" || ( ECHO Не удалось перейти в папку с распакованным архивом.  & PAUSE & EXIT /B )
FOR /R %%I IN ("AsusSetup*.exe" "InsAMDA*.exe") DO IF EXIST "%%~I" (
    SET "installerDir=%%~dpI"
    SET "installer=%%~I"
    SET "switch=-s"
    GOTO :foundInstallerExe
)
FOR /R %%I IN ("*.exe") DO IF EXIST "%%~I" (
    SET "installer=%%~I"
    SET "installerDir=%%~dpI"
    SET "switch=/s"
    GOTO :foundInstallerExe
)
POPD
ECHO Не найден исполняемый файл для установки! & PAUSE & EXIT /B
:foundInstallerExe
POPD
START "Установка ASUS ACPI PNP0A0A" /WAIT /D "%installerDir%" "%installer%" %switch%
IF ERRORLEVEL 1 ( PAUSE ) ELSE ( PING 127.0.0.1 -n 5 ) >NUL
RD /S /Q "%tempout%"
