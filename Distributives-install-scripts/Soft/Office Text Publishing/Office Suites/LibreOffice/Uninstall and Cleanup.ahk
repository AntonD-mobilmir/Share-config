#NoEnv
#SingleInstance ignore
Menu Tray, Tip, LibreOffice uninstall and cleanup
EnvGet RunInteractiveInstalls,RunInteractiveInstalls

if not A_IsAdmin
{
    If (RunInteractiveInstalls!="0")
    {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
	ExitApp
    }
}

SetRegView 32
InstallLocation=

;see http://wpkg.org/LibreOffice for list of GUIDs
Loop Reg, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, K
{
    RegRead DisplayName, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, DisplayName
    If (SubStr(DisplayName, 1, 12)!="LibreOffice ")
	Continue
    
    RegRead URLInfoAbout, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, URLInfoAbout
    If URLInfoAbout != http://www.documentfoundation.org
	Continue

    RegRead InstallLocation, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, InstallLocation
    If (!CompareSubstr(InstallLocation,"C:\Program Files\LibreOffice") && !CompareSubstr(InstallLocation, "C:\Program Files (x86)\LibreOffice") )
	Continue
    TrayTip Uninstalling LibreOffice, Found %DisplayName% (GUID %A_LoopRegName%)`, uninstalling,,16
TryUninstallAgain:
    RunWait "%A_WinDir%\System32\MsiExec.exe" /X%A_LoopRegName% /quiet /norestart,,UseErrorLevel
    If (ErrorLevel) {
	If (ErrorLevel==1618) { ; Another install is currently in progress
	    TrayTip %A_ScriptName%, Error 1618: Another install currently in progress`, waiting 30 sec to repeat
	    Sleep 30000
	    GoTo TryUninstallAgain
	} Else If (ErrorLevel!=3010) { ;3010: restart required
	    If (RunInteractiveInstalls!="0")
		MsgBox Error %ErrorLevel% uninstalling %DisplayName% (GUID %A_LoopRegName%)
	    Exit %ErrorLevel%
	}
    }
}

If (InstallLocation) {
    TrayTip Uninstalling LibreOffice, Removing %InstallLocation%,,16
    FileRemoveDir %InstallLocation%, 1
} Else {
    If (RunInteractiveInstalls!="0")
	MsgBox LibreOffice не найден в списке установки и удаления программ.
    Exit 1
}

CompareSubstr(str1,str2) {
    l1:=StrLen(str1)
    l2:=StrLen(str2)
    
    If (l1>l2)
	ml:=l2
    Else
	ml:=l1
    
    return SubStr(str1,1,ml)=SubStr(str2,1,ml)
    return SubStr(str1,1,ml)=SubStr(str2,1,ml)
}
