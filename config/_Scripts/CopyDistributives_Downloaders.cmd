@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    SET "robocopyDcopy=DAT"
    CALL "%~dp0CheckWinVer.cmd" 8 || SET "robocopyDcopy=T"
)
(
    IF NOT EXIST "D:\Distributives\Soft\Archivers Packers\7Zip" MKDIR "D:\Distributives\Soft\Archivers Packers\7Zip"
    %SystemRoot%\System32\robocopy.exe "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Archivers Packers\7Zip" "D:\Distributives\Soft\Archivers Packers\7Zip" /MIR /DCOPY:%robocopyDcopy% /SL /XO /ETA /XF *.exe
    
    IF NOT EXIST "D:\Distributives\Soft\Graphics\Viewers Managers\FreeVimager" MKDIR "D:\Distributives\Soft\Graphics\Viewers Managers\FreeVimager"
    %SystemRoot%\System32\robocopy.exe "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Graphics\Viewers Managers\FreeVimager" "D:\Distributives\Soft\Graphics\Viewers Managers\FreeVimager" /MIR /DCOPY:%robocopyDcopy% /SL /XO /ETA /XF *.exe
    
    IF NOT EXIST "D:\Distributives\Soft\Keyboard Tools\AutoHotkey" MKDIR "D:\Distributives\Soft\Keyboard Tools\AutoHotkey"
    %SystemRoot%\System32\robocopy.exe "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Keyboard Tools\AutoHotkey" "D:\Distributives\Soft\Keyboard Tools\AutoHotkey" /MIR /DCOPY:%robocopyDcopy% /SL /XO /ETA /XF *.exe /XD "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Keyboard Tools\AutoHotkey\Libs" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Keyboard Tools\AutoHotkey\old" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Keyboard Tools\AutoHotkey\Standalone" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Keyboard Tools\AutoHotkey\temp" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Keyboard Tools\AutoHotkey\Utils"
    
    IF NOT EXIST "D:\Distributives\Soft\Keyboard Tools\Punto Switcher" MKDIR "D:\Distributives\Soft\Keyboard Tools\Punto Switcher"
    %SystemRoot%\System32\robocopy.exe "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Keyboard Tools\Punto Switcher" "D:\Distributives\Soft\Keyboard Tools\Punto Switcher" /MIR /DCOPY:%robocopyDcopy% /SL /XO /ETA /XF PuntoSwitcherSetup.exe "PuntoSwitcherSetup 3.1.1.exe" setup_ps295.exe
    
    IF NOT EXIST "D:\Distributives\Soft\MultiMedia\Players\foobar2000" MKDIR "D:\Distributives\Soft\MultiMedia\Players\foobar2000"
    %SystemRoot%\System32\robocopy.exe "\\Srv1S-B.office0.mobilmir\Distributives\Soft\MultiMedia\Players\foobar2000" "D:\Distributives\Soft\MultiMedia\Players\foobar2000" /MIR /DCOPY:%robocopyDcopy% /SL /XO /ETA /XF *.exe

    IF NOT EXIST "D:\Distributives\Soft\Network\HTTP\Google Chrome" MKDIR "D:\Distributives\Soft\Network\HTTP\Google Chrome"
    %SystemRoot%\System32\robocopy.exe "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Network\HTTP\Google Chrome" "D:\Distributives\Soft\Network\HTTP\Google Chrome" /MIR /DCOPY:%robocopyDcopy% /SL /XO /ETA /XF policy_templates.zip *.msi

    IF NOT EXIST "D:\Distributives\Soft\Network\HTTP\Mozilla FireFox" MKDIR "D:\Distributives\Soft\Network\HTTP\Mozilla FireFox"
    %SystemRoot%\System32\robocopy.exe "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Network\HTTP\Mozilla FireFox" "D:\Distributives\Soft\Network\HTTP\Mozilla FireFox" /MIR /DCOPY:%robocopyDcopy% /SL /XO /ETA /XF *.exe /XD "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Network\HTTP\Mozilla FireFox\temp" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Network\HTTP\Mozilla FireFox\latest-mozilla-central" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Network\HTTP\Mozilla FireFox\utilities" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Network\HTTP\Mozilla FireFox\W2K"

    IF NOT EXIST "D:\Distributives\Soft\Network\Mail News\Mozilla Thunderbird" MKDIR "D:\Distributives\Soft\Network\Mail News\Mozilla Thunderbird"
    %SystemRoot%\System32\robocopy.exe "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Network\Mail News\Mozilla Thunderbird" "D:\Distributives\Soft\Network\Mail News\Mozilla Thunderbird" /MIR /DCOPY:%robocopyDcopy% /SL /XO /ETA /XF *.exe /XD "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Network\Mail News\Mozilla Thunderbird\temp" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Network\Mail News\Mozilla Thunderbird\Extensions" "\\Srv1S-B.office0.mobilmir\Distributives\Soft\Network\Mail News\Mozilla Thunderbird\W2K"

rem     IF NOT EXIST "D:\Distributives\Soft\^" MKDIR "D:\Distributives\Soft\^"
rem     %SystemRoot%\System32\robocopy.exe "\\Srv1S-B.office0.mobilmir\Distributives\Soft\^" "D:\Distributives\Soft\^" /MIR /DCOPY:%robocopyDcopy% /SL /XO /ETA /XF *.exe

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

rem START "Копирование дистрибутивов" /MIN /D "%localDist%" %comspec% /U /C "%localDist%\rsync_DistributivesFromSrv0.cmd"
