#NoEnv

ConfDst=%A_AppData%
ConfDstTest=%ConfDst%\GHISLER\wincmd.ini

EnvGet runInteractiveInstalls, RunInteractiveInstalls
EnvGet SetUserSettings,SetUserSettings
If (SetUserSettings=="1")
    overwriteConfig:=1

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
	MsgBox 35,, Total Commander config files exist.`nReplace?
	IfMsgBox Cancel
	    Exit
	IfMsgBox Yes
	    overwriteConfig:=1
	IfMsgBox No
	    overwriteConfig:=0
    }
}

If (InStr(FileExist(A_WinDir . "\SysNative"), "D"))
    SysNative := A_WinDir . "\SysNative"
Else
    SysNative := A_WinDir . "\system32"

FileCopyDir %A_ScriptDir%\APPDATA.DEF,%A_APPDATA%,%overwriteConfig%
IfExist %A_APPDATA%\GHISLER\wincmd.key
    Run %SysNative%\cipher.exe /E "%A_APPDATA%\GHISLER\wincmd.key",,Min
IfExist %A_APPDATA%\GHISLER\pci.db
{
    Run %SysNative%\compact.exe /C /EXE:LZX "%A_APPDATA%\GHISLER\pci.db",,Min
    If (ErrorLevel)
	Run %SysNative%\compact.exe /C "%A_APPDATA%\GHISLER\pci.db",,Min
}

RegDelete HKEY_CURRENT_USER\Software\Ghisler\Total Commander
RegDelete HKEY_LOCAL_MACHINE\Software\Ghisler\Total Commander
