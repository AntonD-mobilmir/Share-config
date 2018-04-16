SET reg=REG.exe
IF EXIST "%SYSTEMROOT%\SysWOW64\REG.EXE" SET REG="%SYSTEMROOT%\SysWOW64\REG.EXE"

FOR %%A IN (32 64) DO (
    %REG% DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SunJavaUpdateSched" /f /reg:%%~A
    %REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Plug-in\1.6.0_12" /v "HideSystemTrayIcon" /t REG_DWORD /d 1 /f /reg:%%~A
)
FOR %%B IN (EnableJavaUpdate EnableAutoUpdateCheck NotifyDownload NotifyInstall) DO %REG% ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v "%%~B" /t REG_DWORD /d 0 /f
"%ProgramFiles%\Java\jre6\bin\jqs" -unregister
"%ProgramFiles(x86)%\Java\jre6\bin\jqs" -unregister

rem Java Auto Update
msiexec.exe /x {4A03706F-666A-4037-7777-5F2748764D10} /qn
