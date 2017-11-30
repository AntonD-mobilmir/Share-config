@REM coding:OEM

%SystemRoot%\System32\taskkill.exe /F /IM igfxHK.exe
%SystemRoot%\System32\taskkill.exe /F /IM igfxTray.exe

REM Service for Intel(R) HD Graphics Control Panel	Intel Corporation	c:\windows\system32\igfxcuiservice.exe	07.03.2014 20:03
SC CONFIG "igfxCUIService1.0.0.0" start= disabled
SC STOP "igfxCUIService1.0.0.0"

REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "HotKeysCmds" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "IgfxTray" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Persistence" /f

REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\igfxcui" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\igfxDTCM" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\igfxOSP" /f

ATTRIB +H "%PUBLIC%\Desktop\Intel*.lnk"
