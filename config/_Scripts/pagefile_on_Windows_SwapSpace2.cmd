@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

IF DEFINED PROCESSOR_ARCHITEW6432 (
    "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
    EXIT /B
)

REG ADD "HKEY_CURRENT_USER\Software\Sysinternals\Movefile" /v EulaAccepted /t REG_DWORD /d 1 /f
IF NOT DEFINED movefileexe CALL "%~dp0find_exe.cmd" movefileexe movefile.exe "%SystemDrive%\SysUtils\SysInternals\movefile.exe"
)
(
IF DEFINED movefileexe FOR /F "usebackq tokens=3* delims=	" %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles"`) DO %movefileexe% "%%~I" ""
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "?:\Windows\SwapSpace\pagefile.sys 1920 1920\0?:\Windows\SwapSpace2\pagefile.sys 1920 1920" /f
ECHO y| CHKDSK "%SystemRoot%\SwapSpace" /L:2048 /X
ECHO y| CHKDSK "%SystemRoot%\SwapSpace" /L:2048
ECHO y| CHKDSK "%SystemRoot%\SwapSpace2" /L:2048 /X
ECHO y| CHKDSK "%SystemRoot%\SwapSpace2" /L:2048

EXIT /B
)
