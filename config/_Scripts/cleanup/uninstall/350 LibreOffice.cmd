@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
)
(
    FOR /D %%I IN ("%ProgramFiles32%\LibreOffice*") DO IF EXIST "%%~I\program\soffice.exe" CALL :CheckMSIInSubdirs "%SoftSourceDir%\Office Text Publishing\Office Suites\LibreOffice\32-bit\LibreOffice_*_Win_x86.msi" "%SoftSourceDir%\Office Text Publishing\Office Suites\LibreOffice\LibreOffice_*.msi" && GOTO :UninstallLO
    FOR /D %%I IN ("%ProgramFiles64%\LibreOffice*") DO IF EXIST "%%~I\program\soffice.exe" CALL :CheckMSIInSubdirs "%SoftSourceDir%\Office Text Publishing\Office Suites\LibreOffice\64-bit\LibreOffice_*_Win_x64.msi" "%SoftSourceDir%\Office Text Publishing\Office Suites\LibreOffice\LibreOffice_*.msi" && GOTO :UninstallLO

    ECHO LibreOffice не найден
EXIT /B 1
)
:UninstallLO
(
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Office Text Publishing\Office Suites\LibreOffice\install.ahk"
    ECHO %DATE% %TIME% Удаление LibreOffice
    %SystemRoot%\System32\taskkill.exe /F /IM soffice.bin
    %AutohotkeyExe% "%SoftSourceDir%\Office Text Publishing\Office Suites\LibreOffice\Uninstall and Cleanup.ahk"
EXIT /B
)
:CheckMSIInSubdirs <dir\mask*.msi> [<dir\mask*.msi> [...]]
(
    FOR /R "%~dp1" %%A IN ("%~nx1") DO IF EXIST "%%~A" EXIT /B 0
    IF "%~2"=="" EXIT /B 1
    SHIFT
GOTO :CheckMSIInSubdirs
)
