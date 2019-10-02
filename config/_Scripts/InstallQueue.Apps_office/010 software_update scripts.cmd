@(REM coding:CP866
IF NOT DEFINED logfile SET logfile="%SystemRoot%\Logs\%~n0.log"
IF NOT DEFINED configDir CALL :GetConfigDir
)
(
rem START "Software Update Scripts Installer" /I %comspec% /C ""%configDir%..\software_update\_install\install_software_update_scripts.cmd" /InstallAndMark"
rem START "Software Update Scripts Installer" /I %comspec% /C ""\\Srv0.office0.mobilmir\profiles$\Share\software_update\_install\install_software_update_scripts.cmd" /InstallAndMark"
START "Software Update Scripts Installer" /I %comspec% /C ""\\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\software_update\_install\install_software_update_scripts.cmd" /InstallAndMark"
EXIT /B
)

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
