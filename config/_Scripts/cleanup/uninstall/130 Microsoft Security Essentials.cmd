@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
)
(
    IF EXIST "%ProgramFiles64%\Microsoft Security Client\Setup.exe" SET "MSSEInstalled=1"
    IF EXIST "%ProgramFiles32%\Microsoft Security Client\Setup.exe" SET "MSSEInstalled=1"
    IF EXIST "%SystemDrive%\Program Files\Microsoft Security Client\Setup.exe" SET "MSSEInstalled=1"
    IF EXIST "%SystemDrive%\Program Files (x86)\Microsoft Security Client\Setup.exe" SET "MSSEInstalled=1"
)
IF "%MSSEInstalled%"=="1" IF EXIST "%SoftSourceDir%\AntiViruses AntiTrojans\Microsoft Security Essentials\%OSWordSize%bit\mseinstall.exe" (
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\AntiViruses AntiTrojans\Microsoft Security Essentials\install.ahk"
    ECHO %DATE% %TIME% Удаление Microsoft Security Essentials
    %AutohotkeyExe% "%SoftSourceDir%\AntiViruses AntiTrojans\Microsoft Security Essentials\uninstall.ahk"
    "%SystemRoot%\System32\ping.exe" 127.0.0.1 -n 15 >NUL
    RD /S /Q "%ProgramData%\Microsoft\Microsoft Antimalware"
)
