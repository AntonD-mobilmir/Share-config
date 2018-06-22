;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot
If (!FileExist((sysNative := SystemRoot "\SysNative") "\cmd.exe"))
    sysNative := SystemRoot "\System32"

defaultConfigDir = \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config
configScriptsDir = %A_ScriptDir%\..
If (!InStr(FileExist(configDir := defaultConfigDir), "D")) {
    FileCreateShortcut %SystemRoot%\explorer.exe, %A_Desktop%\config@Srv1S-B.lnk,, /open`,"%defaultConfigDir%"
    configDir := %configScriptsDir%\..
}
FileCreateShortcut %SystemRoot%\explorer.exe, %A_Desktop%\config.lnk,, /open`,"%configDir%"

If (!A_IsAdmin) {
    RunWait % "*RunAs " DllCall( "GetCommandLine", "Str" ),,UseErrorLevel  ; Requires v1.0.92.01+
    ExitApp
}

RunWait %sysNative%\bcdedit.exe /set nx optout, %A_Temp%
RunWait %sysNative%\wbem\WMIC.exe recoveros set DebugInfoType = 0, %A_Temp%
Run %comspec% /C "%configScriptsDir%\Windows Components\WindowsComponentsSetup.cmd", %A_Temp%

OSVersionObj := RtlGetVersion()
AppXSupported := OSVersionObj[2] > 6 || (OSVersionObj[2] = 6 && OSVersionObj[3] >= 2) ; 10 or 6.[>2] : 6.0 → Vista, 6.1 → Win7, 6.2 → Win8, 6.3 → 8.1, ≥6.4 → Win10

If (AppXSupported)
    Run %comspec% /C "%configScriptsDir%\Windows 10 right after OOBE.cmd", %A_Temp%

Run %comspec% /C "%configScriptsDir%dontIncludeRecommendedUpdates.cmd", %A_Temp%

EnvSet Write-trello-id.ahk-params, /nag
Run %comspec% /C "%configDir%\..\Inventory\collector-script\SaveArchiveReport.cmd", %A_Temp%
;ToDo: сначал тихий поиск карточки, и, если карточка не найдена, проверка/запрос смены hostname.
; стандартный hostname в Win10: DESKTOP-*

ExitApp

#include %A_LineFile%\..\..\..\_Scripts\Lib\RtlGetVersion.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\getDefaultConfig.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\find7zexe.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\ReadSetVarFromBatchFile.ahk
;#include %A_LineFile%\..\..\..\_Scripts\Lib\find_exe.ahk
