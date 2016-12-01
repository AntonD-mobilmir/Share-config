;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv

if not A_IsAdmin
{
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    if Not ErrorLevel = ERROR
	Exit
}

;ExecuteCommandFromRegistry("HKLM","SOFTWARE\Clients\StartMenuInternet\Opera\InstallInfo","ReinstallCommand")
;ExecuteCommandFromRegistry("HKLM","SOFTWARE\Clients\StartMenuInternet\Opera\InstallInfo","ShowIconsCommand")

ExecuteCommandFromRegistry("HKLM","SOFTWARE\Clients\StartMenuInternet\Google Chrome\InstallInfo","ReinstallCommand")
ExecuteCommandFromRegistry("HKLM","SOFTWARE\Clients\StartMenuInternet\Google Chrome\InstallInfo","ShowIconsCommand")

;    shmgrate.exe OCInstallHideIE
ExecuteCommandFromRegistry("HKLM","SOFTWARE\Clients\StartMenuInternet\IEXPLORE.EXE\InstallInfo","HideIconsCommand")

;    "%ProgramFiles%\Mozilla Thunderbird\uninstall\helper.exe" /ShowShortcuts
ExecuteCommandFromRegistry("HKLM","SOFTWARE\Clients\Mail\Mozilla Thunderbird\InstallInfo","ShowIconsCommand")

;    "%ProgramFiles%\Mozilla Thunderbird\uninstall\helper.exe" /SetAsDefaultAppGlobal
ExecuteCommandFromRegistry("HKLM","SOFTWARE\Clients\Mail\Mozilla Thunderbird\InstallInfo","ReinstallCommand")

ExecuteCommandFromRegistry("HKLM","SOFTWARE\Clients\Mail\Opera\InstallInfo","HideIconsCommand")

;    shmgrate.exe OCInstallHideOE
ExecuteCommandFromRegistry("HKLM","SOFTWARE\Clients\Mail\Outlook Express\InstallInfo","HideIconsCommand")
ExecuteCommandFromRegistry("HKLM","SOFTWARE\Clients\Mail\Windows Mail\InstallInfo","HideIconsCommand")

;    %windir%\INF\unregmp2.exe /HideWMP /SetShowState
ExecuteCommandFromRegistry("HKLM","SOFTWARE\Clients\Media\Windows Media Player\InstallInfo","HideIconsCommand")

ExecuteCommandFromRegistry(RootKey,SubKey,ValueName="") {
    RegRead ExecuteCmd,%RootKey%,%SubKey%,%ValueName%
    If ErrorLevel
	return % ErrorLevel+1000
    RunWait %ExecuteCmd%,,UseErrorLevel
    return %ErrorLevel%
}