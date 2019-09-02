@(REM coding:CP866
IF NOT DEFINED logfile SET logfile="%SystemRoot%\Logs\%~n0.log"
IF NOT DEFINED configDir CALL :GetConfigDir
ECHO %DATE% %TIME% Run UserBenchmark
)
IF NOT DEFINED AutoHotkeyExe CALL "%configDir%_Scripts\FindAutoHotkeyExe.cmd"
(
START "" /LOW %AutoHotkeyExe% "%configDir%_Scripts\GUI\Run_UserBenchMark.ahk"
rem  >>%logfile% 2>&1
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
