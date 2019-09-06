@(REM coding:CP866
IF NOT DEFINED logfile SET logfile="%SystemRoot%\Logs\%~n0.log"
IF NOT DEFINED configDir CALL :GetConfigDir
)
IF NOT DEFINED DistSourceDir CALL "%ConfigDir%_Scripts\FindSoftwareSource.cmd"
(
    SETLOCAL
    (
    CALL "%SoftSourceDir%\Network\Remote Control\Remote Desktop\TeamViewer 5\install.cmd" TeamViewer_Host.MSI
    ) >>%logfile% 2>&1
    ENDLOCAL
    PING 127.0.0.1 -n 10>NUL
    %SystemRoot%\System32\sc.exe start TeamViewer5

    START "Collecting inventory information with TeamViewer ID" /I %comspec% /C "\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Inventory\collector-script\SaveArchiveReport.cmd"
EXIT /B
)

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
