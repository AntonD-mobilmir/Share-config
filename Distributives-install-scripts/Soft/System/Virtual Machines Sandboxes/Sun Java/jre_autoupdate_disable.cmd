SET reg=REG.exe
IF EXIST "%SYSTEMROOT%\SysWOW64\REG.EXE" SET REG="%SYSTEMROOT%\SysWOW64\REG.EXE"

%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Plug-in\1.6.0_12" /v HideSystemTrayIcon /t REG_DWORD /d 1 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableJavaUpdate /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableAutoUpdateCheck /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyDownload /t REG_DWORD /d 0 /f
%REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyInstall /t REG_DWORD /d 0 /f
%REG% DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v SunJavaUpdateSched /f

"%ProgramFiles%\Java\jre6\bin\jqs" -unregister

rem Java Auto Update
msiexec.exe /x {4A03706F-666A-4037-7777-5F2748764D10} /qn
