@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF NOT DEFINED xlnexe CALL "..\..\..\profiles$\Share\config\_Scripts\find_exe.cmd" xlnexe xln.exe c:\SysUtils\xln.exe "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\xln.exe" || EXIT /B -1
IF NOT DEFINED exe7z CALL "..\..\..\profiles$\Share\config\_Scripts\find7zexe.cmd" || EXIT /B -1
)
(
%exe7z% x -aoa -o"%USERPROFILE%\Git\Share-config\Distributives_unpacked\Soft\PreInstalled\manual\TotalCommander.config" -x!"pci.db" -x!*.key -- "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\manual\TotalCommander.config.7z"
)
