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
    configDir = %configScriptsDir%\..
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

;ToDo: сначала тихий поиск карточки, и, если карточка не найдена, проверка/запрос смены hostname.
RunWait %comspec% /C "%configDir%\..\Inventory\collector-script\SaveArchiveReport.cmd", %A_Temp%
If (!FileExist(A_AppDataCommon "\mobilmir.ru\trello-id.txt")) {
    RegRead Hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
    ; стандартный hostname в Win10: DESKTOP-*
    If (StartsWith(Hostname, "DESKTOP-")) {
        InputBox newHostname, Hostname, Введите действительный Hostname,,,,,,,, %Hostname%
        If (newHostname && newHostname != Hostname) {
            MsgBox 0x24, Hostname изменён, Записать в реестр hostname "%newHostname%" вместо "%Hostname%"?
            IfMsgBox Yes
                UpdateHostname(newHostname)
        }
    }
    
    EnvSet Write-trello-id.ahk-params, /nag
    Run %comspec% /C "%configDir%\..\Inventory\collector-script\SaveArchiveReport.cmd", %A_Temp%
}

MsgBox 0x24, Система на SSD?, Перенести индекс поиска Windows на D: ?
IfMsgBox Yes
    Run "%A_AhkPath%" "%A_ScriptDir%\Move Windows Search Index to D.ahk"

ExitApp

#include %A_LineFile%\..\..\..\_Scripts\Lib\RtlGetVersion.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\getDefaultConfig.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\find7zexe.ahk
#include %A_LineFile%\..\..\..\_Scripts\Lib\ReadSetVarFromBatchFile.ahk
;#include %A_LineFile%\..\..\..\_Scripts\Lib\find_exe.ahk

UpdateHostname(newHostname) {
    global sysNative
    ; does not work RegWrite REG_SZ, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname, %newHostname%
    
    RunWait %sysNative%\wbem\wmic.exe computersystem where caption='%A_ComputerName%' rename '%newHostname%'
    ;rename vbscript: https://docs.microsoft.com/ru-ru/windows/desktop/CIMWin32Prov/rename-method-in-class-win32-computersystem
    
    ;https://autohotkey.com/board/topic/60968-wmi-tasks-com-with-ahk-l/
;    strComputer:="."
;    objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")
;    objWMIService.ExecMethod("computersystem", "rename", newHostname)
;    objWMIService :=
    
;    If (winUserFullName) {
;	StringSplit sFIOpt, winUserFullName, %A_Space%
;	If (sFIOpt0 == 3) ; Фамилия Имя Отчество
;	    return sFIOpt2 " " sFIOpt1
;	Else If (!ParsedParts) {
;	    ParsedOnly := sFIOpt0
;	    return winUserFullName
;	}
;    }
}

StartsWith(ByRef long, ByRef short) {
    return SubStr(long, 1, StrLen(short)) = short
}
