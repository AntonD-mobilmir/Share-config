@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    IF NOT EXIST "D:\Distributives\Soft" MKDIR "D:\Distributives\Soft"
    %SystemRoot%\System32\robocopy.exe "\\Srv1S-B.office0.mobilmir\Distributives\Soft" "D:\Distributives\Soft" /MIR /DCOPY:DAT /SL /XO /ETA /XD "\\Srv1S-B.office0.mobilmir\Distributives\Soft\AntiViruses AntiTrojans\Microsoft Security Essentials" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Network\Chat Messengers" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Office Text Publishing\Text Documents" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\PreInstalled\manual"
EXIT /B
)
rem IF NOT DEFINED exe7z CALL "%~dp0find7zexe.cmd" || PAUSE

rem SET localDist=D:\Distributives
rem FOR /R %localDist% %%I IN (".sync*") DO (
rem     IF "%%~nxI"==".sync" DEL "%%~I"
rem     IF "%%~nxI"==".sync.includes" DEL "%%~I"
rem     IF "%%~nxI"==".sync.excludes" DEL "%%~I"
rem )

rem %exe7z% x -aoa -y -o"%localDist%" -- "%~dpn0.syncmarker.7z"
rem XCOPY "%~dp0rsync_DistributivesFromSrv0.cmd" "%localDist%" /Y /I

rem START "����஢���� ����ਡ�⨢��" /MIN /D "%localDist%" %comspec% /U /C "%localDist%\rsync_DistributivesFromSrv0.cmd"
