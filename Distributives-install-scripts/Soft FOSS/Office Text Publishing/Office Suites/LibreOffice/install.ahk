#NoEnv
#SingleInstance ignore

global textTrayTip := "Installing LibreOffice"
Menu Tray, Tip, %textTrayTip%

EnvGet RunInteractiveInstalls,RunInteractiveInstalls
If (!A_IsAdmin) {
    If (RunInteractiveInstalls!=0) {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
    }
    ExitApp -1
}

AhkParm=
If (!RunInteractiveInstalls)
    AhkParm=/ErrorStdOut

If (A_Is64bitOS)
    distsToTry := [["64", "64-bit"]] ; [distSuffix, distSubdir]
Else
    distsToTry := []

distsToTry.Push(["86", "32-bit"], [])

For i, distToTry in distsToTry {
    distDir := FirstExisting(A_ScriptDir "\" distToTry[2], A_ScriptDir)
    HelpDistrMask := distDir "\LibreOffice_*_Win_x" distToTry[1] "_helppack_ru.msi"
    If (FileExist(DistributiveMask := distDir "\LibreOffice_*_Win_x" distToTry[1] ".msi"))
	break
}

If (!DistributiveMask)
    Throw Exception("Дистрибутив не найден")

EnvGet logPath,logmsi

RemoveLangpacks 	:= ReadListFromFile(A_ScriptDir . "\remove_langpacks.txt")
RemoveDictionaries 	:= ReadListFromFile(A_ScriptDir . "\remove_dictionaries.txt")
RemoveOtherComponents 	:= ReadListFromFile(A_ScriptDir . "\remove_OtherComponents.txt")

Remove=%RemoveOtherComponents%`,%RemoveLangpacks%
;,%RemoveDictionaries%

; even    QuietInstall := /qb is interactive!!!!, so the only option is /qn
QuietInstall = /qn

;Searching distributives
Loop %DistributiveMask%
    If A_LoopFileFullPath > %Distributive% ; * is less than any digit, so mask will go away first
	Distributive:=A_LoopFileFullPath
If Not Distributive
    CheckError(-1, "Not found distributive with mask """ . DistributiveMask . """, workdir: """ . A_WorkingDir . """")

Loop %HelpDistrMask%
    If A_LoopFileFullPath > %HelpDistr% ; * is less than any digit, so mask will go away first
	HelpDistr=%A_LoopFileFullPath%
;If Not HelpDistr
;    CheckError(-1, "Not found helpfile distributive with mask """ . HelpDistrMask . """, workdir: """ . A_WorkingDir . """")

TrayTip %textTrayTip%, Running Check and close running soffice.bin.ahk
RunWait %A_AhkPath% /ErrorStdOut "%A_ScriptDir%\Check and close running soffice.bin.ahk"
TrayTip

TrayTip %textTrayTip%, Main MSI (Distributive)

If (A_OSVersion=="WIN_7") { ; LO 6.2.3 fails to install on Win7 due to error. To fix that, has to stop Windows Update service prior to installing.
    SplitPath Distributive, MSIFileName
    ;If (StartsWith(MSIFileName, "LibreOffice_6.2.3_Win_")) {
    EnvGet SystemRoot, SystemRoot
    RunWait %SystemRoot%\System32\net.exe stop wuauserv
    restartWuauserv:=1
    ;}
}
ErrorsOccured := ErrorsOccured || InstallMSI(Distributive, QuietInstall . " COMPANYNAME=""группа компаний Цифроград"" ISCHECKFORPRODUCTUPDATE=0 REGISTER_ALL_MSO_TYPES=1 ADDLOCAL=ALL REMOVE=" . Remove . " AgreeToLicense=Yes")
If (restartWuauserv)
    Run %SystemRoot%\System32\net.exe start wuauserv
    
FileSetAttrib +H, %A_DesktopCommon%\LibreOffice *

If (!ErrorsOccured) {
    If (HelpDistr) {
	TrayTip %textTrayTip%, Offline Help MSI (HelpDistr)
	ErrorsOccured := ErrorsOccured || InstallMSI(HelpDistr, QuietInstall)
    }
    If FileExist(A_ScriptDir "\Install_Extensions.ahk") {
        Menu Tray, Tip, Installing Extensions
        TrayTip %textTrayTip%, Extensions
        RunWait "%A_AhkPath%" %AhkParm% "%A_ScriptDir%\Install_Extensions.ahk", %A_ScriptDir%, Min UseErrorLevel
        ErrorsOccured := ErrorsOccured || ErrorLevel
    }

    If (FileExist(A_ScriptDir "\SetDefaults.cmd")) {
	Menu Tray, Tip, Setting up defaults
	TrayTip %textTrayTip%, Setting up defaults
	RunWait %comspec% /C "%A_ScriptDir%\SetDefaults.cmd",%A_ScriptDir%,Min UseErrorLevel
	ErrorsOccured := ErrorsOccured || ErrorLevel
    }
}

Menu Tray, Tip, Compacting LibreOffice directory
TrayTip %textTrayTip%, Compacting LibreOffice directory
RunWait %comspec% /C ""%A_ScriptDir%\CompactLODir.cmd"",,Min

Exit ErrorsOccured

InstallMSI(MSIFileFullPath, params) {
    Global logPath
    
    SplitPath MSIFileFullPath, MSIFileName
    If (!logPath)
	logPath=%A_TEMP%\%MSIFileName%.log
    Menu Tray, Tip, Installing %MSIFileFullPath%
TryInstallAgain:
    RunWait %A_WinDir%\System32\msiexec.exe /i "%MSIFileFullPath%" %params% /norestart /l+* "%logPath%",, UseErrorLevel

    If (ErrorLevel==1618) { ; Another install is currently in progress
	TrayTip %textTrayTip%, Error 1618: Another install currently in progress`, waiting 30 sec to repeat
	Sleep 30000
	GoTo TryInstallAgain
    }
    Menu Tray, Tip, %textTrayTip%
    
    If (ErrorLevel==3010) ;3010: restart required
	return 0
    Else
	return CheckError(ErrorLevel, MSIFileName)
}

CheckError(ReturnErrValue, Description) {
    Global RunInteractiveInstalls,logPath
    If (ReturnErrValue) {
	FileAppend Error %ReturnErrValue% installing %Description%`nLog written to %logPath%, *
	If (RunInteractiveInstalls!=0)
	    MsgBox 48, LibreOffice Installing error, ErrorLevel: %ReturnErrValue%`n%Description%, 30
    } else {
	FileAppend Finished installing %Description%`n, *
    }
    return ReturnErrValue
}

ReadListFromFile(filename) {
    out := ""
    Loop Read, %filename%
    {
	out .= "," . Trim(A_LoopReadLine," `t`n`r")
    }
    return SubStr(out, 2) ; skipping first comma
}

FirstExisting(paths*) {
    for index,path in paths
	If (FileExist(path))
	    return path
    
    return
}

StartsWith(ByRef long, ByRef short) {
    return short = SubStr(long, 1, StrLen(short))
}