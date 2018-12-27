#NoEnv
#SingleInstance ignore

global ScriptTitle := "LibreOffice uninstall and cleanup"
     , silent
     , remainingFolders := {}

Menu Tray, Tip, %ScriptTitle%

EnvGet RunInteractiveInstalls,RunInteractiveInstalls
If (!A_IsAdmin && RunInteractiveInstalls!="0") {
    Run % "*RunAs " . DllCall( "GetCommandLine", "Str" )
    ExitApp
}

If (RunInteractiveInstalls=="0")
    silent := 1
Else
    argsmsiexec = /passive

Loop %0%
{
    arg := %A_Index%
    If (arg = "/q")
	silent := 1
}

regViews := [32], baseDirs := {(A_ProgramFiles): ""}
If (A_Is64bitOS) {
    regViews.Push(64)
    For i, envVar in ["ProgramFiles", "ProgramFiles(x86)", "ProgramW6432"] {
        EnvGet evValue, %envVar%
        If (evValue)
	    baseDirs[evValue] := ""
    }
}

For baseDir in baseDirs {
    For j, leafDirName in ["", " 4", " 5"]
    remainingFolders[baseDir "\LibreOffice" leafDirName] := 0
}

If (silent)
    argsmsiexec = /quiet

uninstCount := 0
For i, regView in regViews {
    SetRegView %regView%
    InstallLocation=
    
    ;see http://wpkg.org/LibreOffice for list of GUIDs
    Loop Reg, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, K
    {
	RegRead DisplayName, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, DisplayName
	If (SubStr(DisplayName, 1, 12)!="LibreOffice ")
	    Continue
	RegRead URLInfoAbout, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, URLInfoAbout
	If (!(URLInfoAbout ~= "https?:\/\/www\.documentfoundation\.org|https?:\/\/www\.libreoffice\.org/"))
	    Continue
        
	RegRead InstallLocation, %A_LoopRegKey%\%A_LoopRegSubKey%\%A_LoopRegName%, InstallLocation
	baseDirFound := 0
	For baseDir in baseDirs
            If (StartsWith(InstallLocation, baseDir "\Libre")) {
                baseDirFound := 1
                break
            }
        If (!baseDirFound)
            continue
        If (!MsiExecExe) {
            EnvGet SystemRoot, SystemRoot
            MsiExecExe := (SystemRoot ? SystemRoot "\System32\" : "") . "MsiExec.exe"
        }
        Loop
        {
            TrayTip %ScriptTitle%, Найден %DisplayName% (GUID %A_LoopRegName%)`, удаление,,16
            RunWait "%MsiExecExe%" /X"%A_LoopRegName%" %argsmsiexec% /norestart,,UseErrorLevel
            If (ErrorLevel) {
                If (ErrorLevel==1618) { ; Another install is currently in progress
                    TrayTip %A_ScriptName%, Ошибка %ErrorLevel%: В данный момент выполняется другая установка`, ожидание 30 с перед повтором.`n`n[попытка %A_Index%]
                    Sleep 30000
                    continue
                } Else If (ErrorLevel!=3010) { ;3010: restart required
                    If (!silent)
                        MsgBox Ошибка %ErrorLevel% при удалении %DisplayName% (GUID %A_LoopRegName%)
                    Exit %ErrorLevel%
                }
            } Else {
                remainingFolders[InstallLocation]++
                uninstCount++
            }
            break
        }
    }
}
If (uninstCount) {
    For InstallLocation in remainingFolders {
        TrayTip %ScriptTitle%, Удаление папки %InstallLocation%,,16
        FileRemoveDir %InstallLocation%, 1
    }
} Else {
    If (!silent)
	MsgBox 0x30, %ScriptTitle%, LibreOffice не найден в списке установки и удаления программ., 120
    ExitApp 1
}
ExitApp 0

StartsWith(ByRef long, ByRef short) {
    return SubStr(long,1,StrLen(short))=short
}
