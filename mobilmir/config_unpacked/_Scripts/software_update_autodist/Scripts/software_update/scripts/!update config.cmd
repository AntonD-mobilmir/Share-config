@(REM coding:CP866
IF NOT "%DefaultsSource:~0,2%"=="\\" (
    CALL "%Distributives%\config\update local config.cmd"
    CALL "%configDir%update local config.cmd"
)
)
