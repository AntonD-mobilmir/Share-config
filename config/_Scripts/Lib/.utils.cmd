@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

REM shared utils for uninstall and install scripts
REM usage:
REM CALL .utils.cmd function-name arguments
)
(
CALL :%*
EXIT /B
)

:MarkForInstall <silent-install-script>
(
REM RunningUninstallName defined in uninstall_soft.cmd
IF NOT DEFINED RunningUninstallName EXIT /B 1
IF NOT DEFINED InstallQueue CALL :GetInstallQueue InstallQueue
CALL :GetNow Now
)
(
IF NOT EXIST "%InstallQueue%" MKDIR "%InstallQueue%"
ECHO @REM Generated %Now% with "%~f0">"%InstallQueue%\%RunningUninstallName%.cmd"

IF "%~x1"==".cmd" SET "prefix=CALL "
IF "%~x1"==".bat" SET "prefix=CALL "
IF "%~x1"==".ahk" (
    ECHO IF NOT DEFINED AutohotkeyExe CALL "%~dp0..\FindAutoHotkeyExe.cmd">>"%InstallQueue%\%RunningUninstallName%.cmd"
    SET "prefix=%%AutohotkeyExe%% "
)

)
(
ECHO ^(
ECHO %prefix%%*
ECHO ^) ^>"%%TEMP%%\%RunningUninstallName%.%%DATE:~-4,4%%-%%DATE:~-7,2%%-%%DATE:~-10,2%% %%TIME::=%%.log"
REM ^&^& DEL "%%~f0"
) >>"%InstallQueue%\%RunningUninstallName%.cmd"
EXIT /B

:GetInstallQueue <var>
(
SET "%~1=%ProgramData%\mobilmir.ru\InstallQueue"
EXIT /B
)
:GetToday <var>
(
SET "%~1=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2%"
EXIT /B
)
:GetNow <var>
(
SET "%~1=%DATE:~-4,4%-%DATE:~-7,2%-%DATE:~-10,2% %TIME::=%"
EXIT /B
)
:CheckSetSystemVars
(
IF NOT DEFINED ProgramData (
    REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "ProgramData" /t REG_EXPAND_SZ /d "%%ALLUSERSPROFILE%%\Application Data" /f
    SET "ProgramData=%ALLUSERSPROFILE%\Application Data"
)
IF NOT DEFINED APPDATA (
    IF EXIST "%USERPROFILE%\Application Data" (
	REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "AppData" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Application Data" /f
	SET "APPDATA=%USERPROFILE%\Application Data"
    ) ELSE (
	ECHO Не удаётся найти папку Application Data
	PAUSE & EXIT
    )
)
EXIT /B
)
:findlatest <path>
(
    CALL :InitRemembering
    FOR %%A IN (%*) DO CALL :RememberIfLatest latestFile "%%A"
EXIT /B
)
:InitRemembering
(
    SET "latestDate=0000000000:00"
EXIT /B
)
:RememberIfLatest <varName> <path>
(
    SETLOCAL
    SET "currentFDate=%~t2"
)
(
@rem     01.12.2011 21:29, so reverse date to get correct comparison
    SET "currentFDate=%currentFDate:~6,4%%currentFDate:~3,2%%currentFDate:~0,2%%currentFDate:~11%"
)
(
    ENDLOCAL
    IF "%currentFDate%" GTR "%latestDate%" (
	SET "%~1=%~2"
	SET "latestDate=%currentFDate%"
    )
EXIT /B
)
:ReadRegHostname <var>
(
FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "%~1=%%~J"
EXIT /B
)
:ReadRegNVHostname <var>
(
FOR /f "usebackq tokens=3*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname"`) DO SET "%~1=%%~J"
EXIT /B
)
:IsOS64Bit
(
IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" EXIT /B 0
IF DEFINED PROCESSOR_ARCHITEW6432 EXIT /B 0
EXIT /B 1
)
:strlen <resultVar> <stringVar>
(   
    rem https://stackoverflow.com/a/5841587
    setlocal EnableDelayedExpansion
    set "s=!%~2!#"
    set "len=0"
    for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!s:~%%P,1!" NEQ "" ( 
            set /a "len+=%%P"
            set "s=!s:~%%P!"
        )
    )
)
( 
    endlocal
    set "%~1=%len%"
    exit /b
)
:GetFileVer <varname> <path>
(
SETLOCAL
SET "fileNameForWMIC=%~2"
)
SET fileNameForWMIC=%fileNameForWMIC:\=\\%
FOR /F "usebackq skip=1" %%I IN (`wmic datafile where Name^="%fileNameForWMIC%" get Version`) DO (
    ENDLOCAL
    SET "%~1=%%~I"
    EXIT /B 0
)
EXIT /B 1
