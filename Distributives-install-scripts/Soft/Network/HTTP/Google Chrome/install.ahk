#NoEnv

EnvGet RunInteractiveInstalls,RunInteractiveInstalls
If (!A_IsAdmin) {
    If (RunInteractiveInstalls!=0) {
	Run % "*RunAs " DllCall( "GetCommandLine", "Str" )
	ExitApp -1
    }
    Throw "Cannot acqure admin rights."
}

If (A_Is64bitOS) {
    distName:="GoogleChromeStandaloneEnterprise64.msi"
} Else {
    distName:="GoogleChromeStandaloneEnterprise.msi"
}

InstallMSI(A_ScriptDir . "\" . distName, "/qn")

FileSetAttrib +H, %A_DesktopCommon%\Google Chrome.lnk
RunWait %comspec% /C ""%A_ScriptDir%\copyDefaultSettings.cmd"", Min UseErrorLevel

ExitApp

InstallMSI(MSIFileFullPath, params) {
    Global LogPath
    static SystemRoot:=""
    If (SystemRoot=="")
	EnvGet SystemRoot, SystemRoot
    
    SplitPath MSIFileFullPath, MSIFileName

    If(!LogPath)
	EnvGet LogPath, logmsi
    If(!LogPath)
	LogPath=%A_TEMP%\%MSIFileName%.log
    Menu Tray, Tip, Installing %MSIFileFullPath%
    
    Loop {
	RunWait "%SystemRoot%\System32\msiexec.exe" /i "%MSIFileFullPath%" %params% /norestart /l+* "%LogPath%",, UseErrorLevel

	If (ErrorLevel==1618) { ; Another install is currently in progress
	    TrayTip %textTrayTip%, Error 1618: Another install currently in progress`, waiting 30 sec to repeat
	    Sleep 30000
	} Else {
	    break
	}
    }
    Menu Tray, Tip, %textTrayTip%
    
    If (ErrorLevel==3010) ;3010: restart required
	return 0
    return CheckError(ErrorLevel, MSIFileName)
}

CheckError(ReturnErrValue, ProductName) {
    Global RunInteractiveInstalls,LogPath
    If (ReturnErrValue) {
	FileAppend Error %ReturnErrValue% installing %ProductName%`nLog written to %LogPath%, *
	If (RunInteractiveInstalls!=0)
	    MsgBox 48, %ProductName% Installing error, ErrorLevel: %ReturnErrValue%, 30
    } else {
	FileAppend Finished installing %ProductName%`n, *
    }
    return ReturnErrValue
}
