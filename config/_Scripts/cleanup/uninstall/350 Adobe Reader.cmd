@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF NOT DEFINED ProgramFiles32 CALL "%~dp0Lib\_init.cmd"
)
FOR /D %%A IN ("%ProgramFiles32%\Adobe\Reader*" "%ProgramFiles32%\Adobe\Acrobat Reader*") DO IF EXIST "%%~A\Reader\AcroRd32.exe" IF EXIST "%SoftSourceDir%\Office Text Publishing\PDF\Adobe Reader\AcroReadDC.7z" (
    CALL "%~dp0..\..\Lib\.utils.cmd" MarkForInstall "%SoftSourceDir%\Office Text Publishing\PDF\Adobe Reader\install.cmd"
    ECHO %DATE% %TIME% Удаление Adobe Reader
    CALL "%SoftSourceDir%\Office Text Publishing\PDF\Adobe Reader\uninstall.cmd"
)
