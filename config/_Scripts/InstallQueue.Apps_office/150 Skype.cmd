@(REM coding:CP866
IF NOT DEFINED logfile SET logfile="%SystemRoot%\Logs\%~n0.log"
IF NOT DEFINED configDir CALL :GetConfigDir
)
(
REM В Windows 10 есть AppX/Metro приложение, без десктопной версии можно обойтись
CALL "%configDir%_Scripts\CheckWinVer.cmd" 10 && EXIT /B

IF NOT DEFINED DistSourceDir CALL "%ConfigDir%_Scripts\FindSoftwareSource.cmd"
)
(
CALL "%SoftSourceDir%\Network\Chat Messengers\Skype\install.cmd"
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
