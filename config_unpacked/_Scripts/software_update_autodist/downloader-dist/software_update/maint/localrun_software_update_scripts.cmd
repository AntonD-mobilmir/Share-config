@(REM coding:CP866
%SystemRoot%\System32\schtasks.exe /Run /TN "mobilmir.ru\SoftwareUpdate"
PING -n 3 127.0.0.1 >NUL
%SystemRoot%\System32\schtasks.exe /Run /TN "mobilmir.ru\SoftwareUpdate"
)
