@REM coding:OEM
IF NOT DEFINED exe7z CALL "%~dp0..\..\..\find7zexe.cmd" || EXIT /B

START "" /D "\\Srv0\Distributives\Drivers\AMD" /B /WAIT %comspec% /C "\\Srv0\Distributives\Drivers\AMD\XP_cpu_drivers.cmd"
START "" /D "\\Srv0\Distributives\Drivers\Realtek\Audio\High_Definition_Audio_Codecs" /B /WAIT %comspec% /C "\\Srv0\Distributives\Drivers\Realtek\Audio\High_Definition_Audio_Codecs\Install.cmd"
