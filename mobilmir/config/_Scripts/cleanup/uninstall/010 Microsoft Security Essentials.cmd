@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF EXIST "%ProgramFiles%\Microsoft Security Client\Setup.exe" SET "MSSEInstalled=1"
    IF EXIST "%lProgramFiles%\Microsoft Security Client\Setup.exe" SET "MSSEInstalled=1"
    IF EXIST "%SystemDrive%\Program Files\\Microsoft Security Client\Setup.exe" SET "MSSEInstalled=1"
    IF EXIST "%SystemDrive%\Program Files (x86)\\Microsoft Security Client\Setup.exe" SET "MSSEInstalled=1"
    SET "OSWordSize=32"
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OSWordSize=64"
    IF /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET "OSWordSize=64"
)
IF "%MSSEInstalled%"=="1" IF EXIST "%SoftSourceDir%\AntiViruses AntiTrojans\Microsoft Security Essentials\%OSWordSize%bit\mseinstall.exe" (
    ECHO %DATE% %TIME% Удаление Microsoft Security Essentials
    %AutohotkeyExe% "%SoftSourceDir%\AntiViruses AntiTrojans\Microsoft Security Essentials\uninstall.ahk"
    "%SystemRoot%\System32\ping.exe" 127.0.0.1 -n 15 >NUL
    RD /S /Q "%ProgramData%\Microsoft\Microsoft Antimalware"
    
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\AntiViruses AntiTrojans\Microsoft Security Essentials\install.ahk"
)
