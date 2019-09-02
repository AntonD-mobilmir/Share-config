@(REM coding:CP866
IF NOT DEFINED logfile SET logfile="%SystemRoot%\Logs\%~n0.log"
IF NOT DEFINED configDir CALL :GetConfigDir
)
(
IF NOT DEFINED DistSourceDir CALL "%configDir%_Scripts\FindSoftwareSource.cmd"
IF NOT DEFINED AutohotkeyExe CALL "%configDir%_Scripts\FindAutoHotkeyExe.cmd"
)
(
%AutohotkeyExe% "%Distributives%\Soft com freeware\MultiMedia\Plugins Frameworks Components\Adobe Flash\install.ahk" /noRunInteractiveInstalls /InstallPlugin /InstallActiveX
) >>%logfile% 2>&1
EXIT /B

:GetConfigDir
CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd"
(
CALL :GetDir configDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
