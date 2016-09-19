@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

START "" /B /WAIT %comspec% /C "\\Srv0.office0.mobilmir\Distributives\Drivers\Intel\Chipset\Chipset Software Installation Utility\install.cmd"
START "" /B /WAIT %comspec% /C "\\Srv0.office0.mobilmir\Distributives\Drivers\Intel\Chipset\Intel Management Engine Interface\WU\Install.cmd"
START "" /B /WAIT %comspec% /C "\\Srv0.office0.mobilmir\Distributives\Drivers\Intel\Graphics\4th gen - Haswell\install.cmd"
START "" /B /WAIT %comspec% /C "\\Srv0.office0.mobilmir\Distributives\Drivers\Intel\Chipset\USB 3.0 XHCI\install_8series.cmd"
START "" /B /WAIT %comspec% /C "\\Srv0.office0.mobilmir\Distributives\Drivers\Realtek\Audio\High_Definition_Audio_Codecs\Install.cmd"
