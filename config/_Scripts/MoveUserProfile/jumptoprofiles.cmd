@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

%SystemRoot%\System32\REG.exe ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /t REG_SZ /v "LastKey" /d "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" /f
START "" /B %SystemRoot%\regedit.exe
)
