@(REM coding:CP866
IF NOT DEFINED logfile SET logfile="%SystemRoot%\Logs\%~n0.log"
IF NOT DEFINED configDir CALL :GetConfigDir
)
(
IF NOT DEFINED DistSourceDir CALL "%ConfigDir%_Scripts\FindSoftwareSource.cmd"
IF NOT DEFINED AutohotkeyExe CALL "%ConfigDir%_Scripts\FindAutoHotkeyExe.cmd"
)
(
%AutohotkeyExe% "%SoftSourceDir%\Office Text Publishing\Office Suites\LibreOffice\install.ahk"
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
