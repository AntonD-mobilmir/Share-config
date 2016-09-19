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
