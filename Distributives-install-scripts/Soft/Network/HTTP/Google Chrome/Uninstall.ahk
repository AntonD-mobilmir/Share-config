;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

EnvGet RunInteractiveInstalls,RunInteractiveInstalls
If (!A_IsAdmin && RunInteractiveInstalls!="0") {
    Run % "*RunAs " . DllCall( "GetCommandLine", "Str" )
    ExitApp
}

SetRegView 32
UninstallAllForCurrentRegView()
SetRegView 64
UninstallAllForCurrentRegView()

UninstallAllForCurrentRegView() {
    RegRead UninstallString, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome, UninstallString
    If (!ErrorLevel && UninstallString) {
	DashPos:=InStr(UninstallString, "-")
	If DashPos
	    UninstallString:=SubStr(UninstallString, 1, DashPos-1)
        
	RunWait "%UninstallString%" --uninstall --multi-install --chrome --system-level --force-uninstall
	If (ErrorLevel)
            Throw Exception(ErrorLevel, UninstallString, A_LastError)
	ChromeProgramFiles:=A_ProgramFiles
	If A_Is64bitOS
	    EnvGet ChromeProgramFiles, ProgramFiles(x86)
	FileRemoveDir %ProgramFiles%\Google\Chrome
    }

    Loop Reg, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, K
    {
	RegRead DisplayName, %A_LoopRegKey%, %A_LoopRegSubKey%\%A_LoopRegName%, DisplayName
	If (DisplayName = "Google Chrome") {
	    RegRead UninstallString, %A_LoopRegKey%, %A_LoopRegSubKey%\%A_LoopRegName%, UninstallString
	    RunWait %UninstallString% /qn /norestart
	}
    }
}
