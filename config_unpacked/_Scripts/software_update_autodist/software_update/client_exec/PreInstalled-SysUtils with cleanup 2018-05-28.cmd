@(REM coding:CP866
ECHO Removing C:\SysUtils
RS /S /Q "%SystemDrive%\SysUtils"
ECHO Running Distributives\Soft\PreInstalled\prepare.cmd ...
CALL "%Distributives%\Soft\PreInstalled\auto\SysUtils.cmd"
ECHO Cleaning non-existing paths from PATH
IF DEFINED AutohotkeyExe (
    %AutohotkeyExe% /ErrorStdOut "%configDir%_Scripts\cleanup\settings\cleanup Path var in reg.ahk"
) ELSE START "" "%configDir%_Scripts\cleanup\settings\cleanup Path var in reg.ahk"
)
