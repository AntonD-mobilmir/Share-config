@(REM coding:CP866
IF NOT DEFINED logfile SET logfile="%SystemRoot%\Logs\%~n0.log"
IF NOT DEFINED configDir CALL :GetConfigDir
)
IF NOT DEFINED DistSourceDir CALL "%ConfigDir%_Scripts\FindSoftwareSource.cmd"
(
SET "xcopyargs=/Y"
CALL "%SoftSourceDir%\PreInstalled\prepare.cmd"
rem IF DEFINED biglogfile START "Installation log" "%SystemDrive%\SysUtils\UnxUtils\tail.exe" -f -n 100 %biglogfile%
) >>%logfile% 2>&1
EXIT /B

:GetConfigDir
CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
(
CALL :GetDir ConfigDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
