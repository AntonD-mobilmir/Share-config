@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    %SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO Скрипт "%~f0" без прав администратора не работает & PING -n 30 127.0.0.1 >NUL & EXIT /B )
    IF DEFINED PROCESSOR_ARCHITEW6432 "%SystemRoot%\SysNative\cmd.exe" /C "%0 %*" & EXIT /B

    rem Disable password expiration
    "%SystemRoot%\System32\net.exe" accounts /maxpwage:unlimited
    rem Disable 8.3 filenames in NTFS filesystem (it's only useful for DOS software)
    "%SystemRoot%\System32\fsutil.exe" behavior set disable8dot3 1

    START "run_collectProductKeys" /MIN %comspec% /C "%~dp0_Scripts\run_collectProductKeys.cmd"

    CALL "%~dp0_Scripts\_software_install.cmd" %*
)
