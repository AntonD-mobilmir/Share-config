@REM coding:CP866
@REM by LogicDaemon <www.logicdaemon.ru>
@REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)

rem REG ADD "%TGT%HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fAllowToGetHelp" /t REG_DWORD /d 0 /f
REG ADD "%TGT%HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t REG_DWORD /d 0 /f
rem shutdown -m \\%1 -t 30 -f -r

CALL "%~dp0CheckWinVer.cmd" 6 && (
    REM Force NLA
    REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "UserAuthentication" /t REG_DWORD /d 1 /f
)
IF ERRORLEVEL 1 (
    REM In Vista+, this only enables firewall for current network type (public / private / domain):
    "%SystemRoot%\system32\netsh.exe" firewall set service type = remotedesktop mode = enable
    EXIT /B
)

REM this enables firewall for all network types (public, private, domain):
rem "%SystemRoot%\system32\netsh.exe" advfirewall firewall set rule group="remote desktop" new enable=yes

"%SystemRoot%\system32\netsh.exe" advfirewall firewall add rule name="Remote Desktop - User Mode (TCP-In)" dir=in action=allow program="%%SystemRoot%%\system32\svchost.exe" service="TermService" description="Inbound rule for the Remote Desktop service to allow RDP traffic. [TCP 3389] added by LogicDaemon's script" enable=yes profile=private,domain localport=3389 protocol=tcp
CALL "%~dp0CheckWinVer.cmd" 6.2 && "%SystemRoot%\system32\netsh.exe" advfirewall firewall add rule name="Remote Desktop - User Mode (UDP-In)" dir=in action=allow program="%%SystemRoot%%\system32\svchost.exe" service="TermService" description="Inbound rule for the Remote Desktop service to allow RDP traffic. [UDP 3389] added by LogicDaemon's script" enable=yes profile=private,domain localport=3389 protocol=udp

rem Windows 10.0.10049 rule names:

rem Rule Name:                            Remote Desktop - Shadow (TCP-In)
rem ----------------------------------------------------------------------
rem Enabled:                              Yes
rem Direction:                            In
rem Profiles:                             Domain,Private
rem Grouping:                             Remote Desktop
rem LocalIP:                              Any
rem RemoteIP:                             Any
rem Protocol:                             TCP
rem LocalPort:                            Any
rem RemotePort:                           Any
rem Edge traversal:                       Defer to application
rem Action:                               Allow

rem Rule Name:                            Remote Desktop - User Mode (UDP-In)
rem ----------------------------------------------------------------------
rem Enabled:                              Yes
rem Direction:                            In
rem Profiles:                             Domain,Private
rem Grouping:                             Remote Desktop
rem LocalIP:                              Any
rem RemoteIP:                             Any
rem Protocol:                             UDP
rem LocalPort:                            3389
rem RemotePort:                           Any
rem Edge traversal:                       No
rem Action:                               Allow

rem Rule Name:                            Remote Desktop - User Mode (TCP-In)
rem ----------------------------------------------------------------------
rem Enabled:                              Yes
rem Direction:                            In
rem Profiles:                             Domain,Private
rem Grouping:                             Remote Desktop
rem LocalIP:                              Any
rem RemoteIP:                             Any
rem Protocol:                             TCP
rem LocalPort:                            3389
rem RemotePort:                           Any
rem Edge traversal:                       No
rem Action:                               Allow
