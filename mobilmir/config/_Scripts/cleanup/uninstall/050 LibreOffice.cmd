@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

FOR /D %%I IN ("%lProgramFiles%\LibreOffice*") DO IF EXIST "%%~I\program\soffice.exe" IF EXIST "%SoftSourceDir%\Office Text Publishing\Office Suites\LibreOffice\*.msi"  (
    ECHO %DATE% %TIME% Удаление LibreOffice
    TASKKILL /F /IM soffice.bin
    %AutohotkeyExe% "%SoftSourceDir%\Office Text Publishing\Office Suites\LibreOffice\Uninstall and Cleanup.ahk"

    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Office Text Publishing\Office Suites\LibreOffice\install.ahk"
)
)
