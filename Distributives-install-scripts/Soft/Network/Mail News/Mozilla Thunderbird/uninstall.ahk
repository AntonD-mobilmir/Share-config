;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

uninstKey = SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
SetRegView 32
Loop Reg, HKEY_LOCAL_MACHINE\%uninstKey%, K
{
    RegRead DisplayName, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, DisplayName
    
    If (StartsWith(DisplayName, "Mozilla Thunderbird ")) {
	RegRead UninstallString, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, UninstallString
	RunWait %UninstallString% /s
    }
}

ExitApp

StartsWith(longtext, shorttext) {
    return SubStr(longtext, 1, StrLen(shorttext)) == shorttext
}

;[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Thunderbird 38.5.1 (x86 ru)]
;"Comments"="Mozilla Thunderbird 38.5.1 (x86 ru)"
;"DisplayIcon"="C:\\Program Files (x86)\\Mozilla Thunderbird\\thunderbird.exe,0"
;"DisplayName"="Mozilla Thunderbird 38.5.1 (x86 ru)"
;"DisplayVersion"="38.5.1"
;"InstallLocation"="C:\\Program Files (x86)\\Mozilla Thunderbird"
;"Publisher"="Mozilla"
;"UninstallString"="C:\\Program Files (x86)\\Mozilla Thunderbird\\uninstall\\helper.exe"
;"URLInfoAbout"="http://www.mozilla.org/ru/"
;"URLUpdateInfo"="http://www.mozilla.org/ru/thunderbird/"
;"NoModify"=dword:00000001
;"NoRepair"=dword:00000001
;"EstimatedSize"=dword:00014380

