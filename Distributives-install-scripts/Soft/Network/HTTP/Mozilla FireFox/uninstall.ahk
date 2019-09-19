;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

uninstKey = SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall

For i, v in [32, 64] {
    SetRegView %v%
    Loop Reg, HKEY_LOCAL_MACHINE\%uninstKey%, K
    {
        RegRead DisplayName, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, DisplayName
        RegRead Publisher, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, Publisher
        
        If (Publisher == "Mozilla" && StartsWith(DisplayName, "Mozilla Firefox ")) {
            RegRead UninstallString, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, UninstallString
            RunWait %UninstallString% /s
        }
    }
}

ExitApp

StartsWith(longtext, shorttext) {
    return SubStr(longtext, 1, StrLen(shorttext)) == shorttext
}

;[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox 44.0 (x86 ru)]
;"Comments"="Mozilla Firefox 44.0 (x86 ru)"
;"DisplayIcon"="C:\\Program Files (x86)\\Mozilla Firefox\\firefox.exe,0"
;"DisplayName"="Mozilla Firefox 44.0 (x86 ru)"
;"DisplayVersion"="44.0"
;"HelpLink"="https://support.mozilla.org"
;"InstallLocation"="C:\\Program Files (x86)\\Mozilla Firefox"
;"Publisher"="Mozilla"
;"UninstallString"="\"C:\\Program Files (x86)\\Mozilla Firefox\\uninstall\\helper.exe\""
;"URLUpdateInfo"="https://www.mozilla.org/firefox/44.0/releasenotes"
;"URLInfoAbout"="https://www.mozilla.org"
;"NoModify"=dword:00000001
;"NoRepair"=dword:00000001
;"EstimatedSize"=dword:00016297
