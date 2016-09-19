@REM coding:CP866
@REM by LogicDaemon <www.logicdaemon.ru>
@REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)


net time \\Srv0 /set /y
net time \\Srv0.office0.mobilmir /set /y

IF NOT "%~1"=="" (
    SET regTGT=\\%~1\
    SET scTGT=\\%1
    SET w32tmTGT=/computer:%1
)

SC %scTGT% START RemoteRegistry
SC %scTGT% CONFIG W32Time start= auto
SC %scTGT% STOP W32Time

CALL "%~dp0CheckWinVer.cmd" 6 && (
    REG ADD "%regTGT%HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "NtpServer" /d "office0.mobilmir.ru,0x4 office.mobilmir.ru,0x4 0.europe.pool.ntp.org 1.europe.pool.ntp.org 2.europe.pool.ntp.org time.nist.gov" /f
    REG ADD "%regTGT%HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "Type" /d "NTP" /f
    REG ADD "%regTGT%HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "MaxNegPhaseCorrection" /t REG_DWORD /d 0xFFFFFFFF /f
    REG ADD "%regTGT%HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "MaxPosPhaseCorrection" /t REG_DWORD /d 0xFFFFFFFF /f
    REG ADD "%regTGT%HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer" /v "Enabled" /t REG_DWORD /d 1 /f
)
SC %scTGT% START W32Time

rem IF "%WinVer%"=="2K" (
rem     w32tm -adjoff
rem     w32tm -s %1
rem     w32tm -once
rem ) ELSE IF "%WinVer%"=="XP" (
rem     sleep time-freeze probable fix http://www.pcreview.co.uk/forums/time-resets-everytime-system-standby-t72425.html
rem     net stop w32time
rem     ping 127.0.0.1 -n 3 >NUL
rem     w32tm /unregister
rem     ping 127.0.0.1 -n 2 >NUL
rem     w32tm /unregister
rem     w32tm /register
    
rem     REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "0" /d "office0.mobilmir.ru,0x4" /f
rem     REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /ve /d "0" /f
    REM XP, 2K3
rem     w32tm /config /syncfromflags:MANUAL %w32tmTGT%
    rem /manualpeerlist:"pool.ntp.org"
rem     w32tm /config /update %w32tmTGT%
rem     w32tm /resync /nowait %w32tmTGT%
rem )
