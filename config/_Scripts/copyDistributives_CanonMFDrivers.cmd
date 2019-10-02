@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    SET "robocopyDcopy=DAT"
    CALL "%~dp0CheckWinVer.cmd" 8 || SET "robocopyDcopy=T"
)
(
    IF NOT EXIST "d:\Distributives\Drivers\Canon\Laser MF" MKDIR "d:\Distributives\Drivers\Canon\Laser MF"
    %SystemRoot%\System32\robocopy.exe "\\Srv1S-B.office0.mobilmir\Distributives\Drivers\Canon\Laser MF" "d:\Distributives\Drivers\Canon\Laser MF" /MIR /DCOPY:%robocopyDcopy% /SL /XO /ETA
    REM /XD "\\Srv1S-B.office0.mobilmir\Distributives\Soft\AntiViruses AntiTrojans\Microsoft Security Essentials" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Network\Chat Messengers" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Office Text Publishing\Text Documents" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\PreInstalled\manual"
EXIT /B
)
