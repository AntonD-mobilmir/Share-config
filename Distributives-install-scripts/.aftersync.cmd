@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT DEFINED exe7z CALL "%~dp0..\..\..\profiles$\Share\config\_Scripts\find7zexe.cmd" || ( ECHO 7z.exe not found & EXIT /B -1 )
)
(
    %exe7z% x -aoa -o"%USERPROFILE%\Git\Share-config\Distributives_unpacked\Soft\PreInstalled\manual\TotalCommander.config" -x!"pci.db" -x!*.key -- "\\Srv1S-B.office0.mobilmir\Distributives\Soft\PreInstalled\manual\TotalCommander.config.7z"
)
