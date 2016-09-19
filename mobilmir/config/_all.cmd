@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
)

IF DEFINED PROCESSOR_ARCHITEW6432 "%SystemRoot%\SysNative\cmd.exe" /C %0 %* & EXIT /B

REM Collect Windows Product Keys information
"%~dp0..\Program Files\collectProductKeys.exe"

rem Disable password expiration
"%SystemRoot%\System32\net.exe" accounts /maxpwage:unlimited
rem Disable 8.3 filenames in NTFS filesystem (it's only useful for DOS software)
"%SystemRoot%\System32\fsutil.exe" behavior set disable8dot3 1

CALL "%~dp0_Scripts\_software_install.cmd" %*
