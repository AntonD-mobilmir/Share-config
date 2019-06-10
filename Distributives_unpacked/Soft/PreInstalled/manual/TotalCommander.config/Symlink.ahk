;HardlinkOrReparse.ahk
; %1% list of objects (files or directories)
; %2% destination where they will be linked

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

;MsgBox % list of objects: %1%`ndestination where they will be linked: %2%

If (!A_IsAdmin) {
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    RunWait *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    if (ErrorLevel = "ERROR")
	MsgBox Без прав администратора ничего не выйдет.
    ExitApp
}

If (A_Args.Length() && FileExist(A_Args[1])) {
    Loop Read, % A_Args[1]
    {
	SplitPath A_LoopReadLine, SrcName, SrcDir ;,,, SrcDrive
        SetTimer showcPID, -3000
	If (!SrcName) {
	    SplitPath SrcDir, SrcName
            If (A_IsAdmin) {
                linkType = Directory Symlink
                RunWait "%comspec%" /C "MKLINK /D "%2%%SrcName%" "%SrcDir%"",,Hide UseErrorLevel, cPID
            }
	} Else {
            linkType = Symlink
            RunWait "%comspec%" /C "MKLINK "%2%%SrcName%" "%A_LoopReadLine%"",,Hide UseErrorLevel, cPID
	}
        SetTimer showcPID, Off
        
	If (ErrorLevel) {
	    errorText = Error %ERRORLEVEL% creating %linkType% for %A_LoopReadLine%`n
	    Errors = %Errors%%errorText%
	    FileAppend %errorText%,*
	} Else {
	    AtLeastOneSucceeded := 1
	}
    }
} Else {
    Errors=Listfile "%1%" does not exist!
    exitError := 4
}

If (Errors || exitError) {
    MsgBox 48, A_ScriptName, Errors occured while linking: %Errors%`nExitError: %exitError%
    Exit exitError ? exitError : 2-AtLeastOneSucceeded
}

showcPID() {
    global cPID
    GroupAdd cshow, ahk_pid %cPID%
    WinShow ahk_group cshow
}
