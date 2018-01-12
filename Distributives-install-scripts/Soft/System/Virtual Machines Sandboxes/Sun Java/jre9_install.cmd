@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

CALL "%~dp0jre_install_common.cmd" "jre-9.*_windows-x64_bin.exe"
REM uninstall previous versions
IF NOT ERRORLEVEL 1 CALL "%~dp0jre_uninstall_common.cmd" /LeaveLast "%~dp0jre9_uids.txt"
)
