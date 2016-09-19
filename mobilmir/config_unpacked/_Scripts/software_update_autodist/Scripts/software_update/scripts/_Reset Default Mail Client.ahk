#NoEnv

;    "%ProgramFiles%\Mozilla Thunderbird\uninstall\helper.exe" /ShowShortcuts
ExecuteCommandFromRegistry("HKLM","SOFTWARE\Clients\Mail\Mozilla Thunderbird\InstallInfo","ShowIconsCommand")

;    "%ProgramFiles%\Mozilla Thunderbird\uninstall\helper.exe" /SetAsDefaultAppGlobal
ExecuteCommandFromRegistry("HKLM","SOFTWARE\Clients\Mail\Mozilla Thunderbird\InstallInfo","ReinstallCommand")

ExecuteCommandFromRegistry(RootKey,SubKey,ValueName="") {
    RegRead ExecuteCmd,%RootKey%,%SubKey%,%ValueName%
    If ErrorLevel
	return % ErrorLevel+1000
    RunWait %ExecuteCmd%,,UseErrorLevel
    return %ErrorLevel%
}
