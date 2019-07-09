#NoEnv

EnvGet runInteractiveInstalls, RunInteractiveInstalls
EnvGet SetUserSettings,SetUserSettings
If (SetUserSettings=="1")
    overwriteConfig:=1

EnvGet SystemRoot, SystemRoot
If (FileExist(SystemRoot "\SysNative\cmd.exe"))
    SysNative := SystemRoot . "\SysNative"
Else
    SysNative := SystemRoot . "\system32"

Loop %0%
{
    switch := %A_Index%
    If (switch = "/silent")
	runInteractiveInstalls:="0"
    Else If (switch = "/force")
	overwriteConfig:=1
    Else {
	If (runInteractiveInstalls=="0") {
	    FileAppend Wrong switch: %switch%`n,**,cp866
	} Else {
	    MsgBox Неправильный параметр командной строки:`n%switch%
	}
	ExitApp 32767
    }
}

baseSrc=%A_ScriptDir%\APPDATA.DEF\GHISLER
baseDst=%A_AppData%\GHISLER

If (!overwriteConfig && FileExist(baseDst "\wincmd.ini")) {
    If (runInteractiveInstalls!="0") {
	MsgBox 0x24, %A_ScriptName%, Total Commander config files exist.`nReplace?
	IfMsgBox No
	    Exit
        FileMoveDir %baseDst%, %baseDst%.%A_Now%.bak, R
        If (ErrorLevel)
            ExitApp
    } Else
	ExitApp
}

FileCreateDir %baseDst%
FileCopyDir %baseSrc%,%baseDst%,1
Run %comspec% /C "%A_ScriptDir%\link_APPDATA.DEF_scripts_to_APPDATA.cmd", %baseSrc%, Min
Run %comspec% /C "%A_ScriptDir%\PlugIns\wdx\TrID_Identifier\TrID\update.cmd", %A_ScriptDir%\..\PlugIns\wdx\TrID_Identifier\TrID, Min
Run "%A_AhkPath%" "%baseDst%\download pci.ids and convert to pci.db.ahk", %baseDst%, Min
RunWait %SysNative%\compact.exe /C /EXE:LZX "%baseDst%\pci.db",,Min
RunWait %SysNative%\compact.exe /C "%baseDst%\pci.db",,Min

RegDelete HKEY_CURRENT_USER\Software\Ghisler\Total Commander
RegDelete HKEY_LOCAL_MACHINE\Software\Ghisler\Total Commander
