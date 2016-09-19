@REM coding:CP866
@REM by LogicDaemon <www.logicdaemon.ru>
@REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

CALL "%~dp0CheckWinVer.cmd" 6 || (
    REM 2000, XP
    shmgrate.exe OCInstallHideIE
    rem HKLM\SOFTWARE\Clients\Mail\Outlook Express\InstallInfo\HideIconsCommand
    shmgrate.exe OCInstallHideOE
    START "" appwiz.cpl
)

"%~dp0SetDefaultAppsHideIEOE.ahk"
EXIT /B

    rem HKEY_LOCAL_MACHINE\SOFTWARE\Clients\StartMenuInternet\Opera\InstallInfo\ReinstallCommand
rem     "%ProgramFiles%\Opera\Opera.exe" /ReInstallBrowser
    rem HKEY_LOCAL_MACHINE\SOFTWARE\Clients\StartMenuInternet\Opera\InstallInfo\ShowIconsCommand
rem     "%ProgramFiles%\Opera\Opera.exe" /ShowIconsCommand
