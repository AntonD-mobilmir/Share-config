PUSHD "%TEMP%"||PAUSE
SET AutohotkeyExe="C:\Program Files\AutoHotkey\AutoHotkey.exe"
SET DefaultsSource=\\Srv0\profiles$\Share\config\Apps_roaming.7z
SET DistSourceDir=\\Srv0.office0.mobilmir\Distributives
SET utilsdir=\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\

SET SoftSourceDir=\\Srv0.office0.mobilmir\Distributives\Soft
(%SystemRoot%\SysWOW64\cmd.exe /C ""%SoftSourceDir%\Network\Remote Control\Remote Desktop\TeamViewer 5\install.cmd" TeamViewer_Host.msi TeamViewer_ServiceNote.reg")|tee tv5inst.log
PAUSE
