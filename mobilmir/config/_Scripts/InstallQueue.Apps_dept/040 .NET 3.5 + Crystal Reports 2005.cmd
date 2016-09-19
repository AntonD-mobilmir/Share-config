@(REM coding:CP866
IF NOT DEFINED logfile SET logfile="%SystemRoot%\Logs\%~n0.log"
IF NOT DEFINED configDir CALL :GetConfigDir
)
(
IF NOT DEFINED DistSourceDir CALL "%ConfigDir%_Scripts\FindSoftwareSource.cmd"
IF NOT DEFINED AutohotkeyExe CALL "%ConfigDir%_Scripts\FindAutoHotkeyExe.cmd"
)
(
PUSHD "%DistSourceDir%\Updates\Windows\wsusoffline\cmd" && (
    CALL DoUpdate.cmd /nobackup /instdotnet35
    POPD
)

CALL "%DistSourceDir%\Soft com freeware\System\Virtual Machines Sandboxes\.NET\addons\install_CRRedist2005_x86.cmd"
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

