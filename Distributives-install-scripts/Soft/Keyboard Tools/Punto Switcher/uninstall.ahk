;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

RunWait "%A_ScriptDir%\PuntoSwitcherSetup.exe" /quiet /norestart
Sleep 5000

uninstKey = SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
SetRegView 32
Loop Reg, HKEY_LOCAL_MACHINE\%uninstKey%, K
{
    RegRead DisplayName, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, DisplayName
    RegRead URLUpdateInfo, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, URLUpdateInfo
    RegRead Publisher, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, Publisher
    
    If (Publisher == "Яндекс" && URLUpdateInfo == "http://punto.yandex.ru" && StartsWith(DisplayName, "Punto Switcher ")) {
	RunWait %A_WinDir%\System32\MsiExec.exe /X "%A_LoopRegName%" /qn /norestart
    }
}

ExitApp

StartsWith(longtext, shorttext) {
    return SubStr(longtext, 1, StrLen(shorttext)) == shorttext
}

;[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{DFD9E015-E5B5-4304-9936-CB9471771424}]
;"DisplayVersion"="4.1.1.479"
;"InstallDate"="20151126"
;"InstallSource"="D:\\Users\\LogicDaemon.dvncg-2.000\\AppData\\Local\\Temp\\{DFD9E015-E5B5-4304-9936-CB9471771424}\\"
;"ModifyPath"=MsiExec.exe /X{DFD9E015-E5B5-4304-9936-CB9471771424}
;"NoModify"=dword:00000001
;"Publisher"="Яндекс"
;"EstimatedSize"=dword:000010ec
;"UninstallString"=MsiExec.exe /X{DFD9E015-E5B5-4304-9936-CB9471771424}
;"URLUpdateInfo"="http://punto.yandex.ru"
;"VersionMajor"=dword:00000004
;"VersionMinor"=dword:00000001
;"WindowsInstaller"=dword:00000001
;"Version"=dword:04010001
;"DisplayName"="Punto Switcher 4.1.1"

;[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{760DFAC7-E011-4318-8E8B-6880EDF46F58}]
;"AuthorizedCDFPrefix"=""
;"Comments"=""
;"Contact"=""
;"DisplayVersion"="4.1.9.903"
;"HelpLink"=""
;"HelpTelephone"=""
;"InstallDate"="20160129"
;"InstallLocation"=""
;"InstallSource"="C:\\Users\\Install\\AppData\\Local\\Temp\\{760DFAC7-E011-4318-8E8B-6880EDF46F58}\\"
;"ModifyPath"=REG_EXPAND_SZ:"MsiExec.exe /X{760DFAC7-E011-4318-8E8B-6880EDF46F58}"
;"NoModify"=dword:00000001
;"Publisher"="Яндекс"
;"Readme"=""
;"Size"=""
;"EstimatedSize"=dword:00001128
;"UninstallString"=REG_EXPAND_SZ:"MsiExec.exe /X{760DFAC7-E011-4318-8E8B-6880EDF46F58}"
;"URLInfoAbout"=""
;"URLUpdateInfo"="http://punto.yandex.ru"
;"VersionMajor"=dword:00000004
;"VersionMinor"=dword:00000001
;"WindowsInstaller"=dword:00000001
;"Version"=dword:04010009
;"Language"=dword:00000000
;"DisplayName"="Punto Switcher 4.1.9"

