;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

Uninstall("K-Lite Codec Pack", "/SILENT", -1)

Uninstall(name, switches, cleanupDir:=0) {
    SetRegView 32
    UninstallAllForCurrentRegView(name, switches, cleanupDir)
    If (A_Is64bitOS) {
	SetRegView 64
	UninstallAllForCurrentRegView(name, switches, cleanupDir)
    }
}

UninstallAllForCurrentRegView(name, switches, cleanupDir) {
    UninstallFromKey("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" . name, switches, cleanupDir)
    Loop Reg, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, K
    {
	regKeyFullPath = %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%
	RegRead DisplayName, %regKeyFullPath%, DisplayName
	If (StartsWith(DisplayName, name))
	    UninstallFromKey(regKeyFullPath, switches, cleanupDir)
    }
}

UninstallFromKey(key, switches, cleanupDir) {
    RegRead UninstallString, %key%, QuietUninstallString
    If (UninstallString) {
	switches=
    } Else {
	RegRead UninstallString, %key%, UninstallString
    }
    If (!ErrorLevel && UninstallString) {
	RunWait %UninstallString% %switches%
	If (!ErrorLevel && cleanupDir) {
	    If (cleanupDir=-1)
		RegRead cleanupDir, %key%, InstallLocation
	    If (FileExist(cleanupDir))
		FileRemoveDir %cleanupDir%
	}
    }
}

StartsWith(longtext, shorttext) {
    return SubStr(longtext, 1, StrLen(shorttext)) == shorttext
}
