#NoEnv

ConfDst=%A_AppData%
ConfDstTest=%ConfDst%\GHISLER\wincmd.ini

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

If (!overwriteConfig && FileExist(ConfDstTest)) {
    If (runInteractiveInstalls!="0") {
	MsgBox 0x24, %A_ScriptName%, Total Commander config files exist.`nReplace?
	IfMsgBox No
	    Exit
    } Else
	Exit
}

FileCopyDir %A_ScriptDir%\APPDATA.DEF,%A_APPDATA%,1
IfExist %A_APPDATA%\GHISLER\wincmd.key
    Run %SysNative%\cipher.exe /E "%A_APPDATA%\GHISLER\wincmd.key",,Min
If (FileExist(A_APPDATA "\GHISLER\pci.db") {
    Run %SysNative%\compact.exe /C /EXE:LZX "%A_APPDATA%\GHISLER\pci.db",,Min
    If (ErrorLevel)
	Run %SysNative%\compact.exe /C "%A_APPDATA%\GHISLER\pci.db",,Min
}

RegDelete HKEY_CURRENT_USER\Software\Ghisler\Total Commander
RegDelete HKEY_LOCAL_MACHINE\Software\Ghisler\Total Commander
