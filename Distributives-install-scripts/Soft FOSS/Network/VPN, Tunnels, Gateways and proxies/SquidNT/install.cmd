(
@REM coding:OEM
CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "c:\Local_Scripts\_get_defaultconfig_source.cmd"
IF DEFINED DefaultsSource ( CALL :Find7zLocally ) ELSE CALL "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\find7zexe.cmd"
IF NOT DEFINED exe7z ( ECHO 7-Zip не найден. & PAUSE & EXIT /B )
)
(
%exe7z% x -o"c:\squid" -- "%~dp0squid.2.7.7z"
PUSHD C:\squid\sbin && (
    CALL install.cmd
    POPD
)
EXIT /B
)
:Find7zLocally
    CALL :GetDir configDir "%DefaultsSource%"
(
    CALL "%configDir%_Scripts\find7zexe.cmd"
EXIT /B
)
:GetDir <var> <path>
(
    SET "%~1=%~dp2"
EXIT /B
)
