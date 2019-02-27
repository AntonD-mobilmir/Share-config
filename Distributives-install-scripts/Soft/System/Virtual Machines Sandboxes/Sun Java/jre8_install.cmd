@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT "%installjre64bit%"=="0" (
        IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
        IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"

        IF DEFINED OS64Bit IF DEFINED installjre64bit (
            CALL "%~dp0jre_install_common.cmd" "jre-8*-windows-x64.exe"
            CALL "%~dp0jre_uninstall_common.cmd" /LeaveLast "%~dp0jre8_uids_64-bit.txt" "%~dp0jre8_uids.txt"
            EXIT /B
        )
    )
    CALL "%~dp0jre_install_common.cmd" "jre-8*-windows-i586.exe"

    REM uninstall previous versions
    CALL "%~dp0jre_uninstall_common.cmd" /LeaveLast "%~dp0jre8_uids.txt"
)
