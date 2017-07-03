#NoEnv
#SingleInstance ignore
logFile=%A_Temp%\%A_ScriptName%.%A_Now%.log
EnvGet LocalAppData, LOCALAPPDATA
If (!(gpgexe:=findexe("gpg.exe", "c:\SysUtils\gnupg\pub", LocalAppData . "\Programs\SysUtils\gnupg\pub"))) {
    FileAppend gpg.exe not found!`n, *
    FileAppend gpg.exe not found!`n, %logFile%
}

arg1=%1%
If (arg1="-batch") {
    runMode=Hide
    unisonExecType=unisontext
} Else {
    unisonExecType=unisongui
}

EnvGet unisonexe, %unisonExecType%
If (!unisonexe)
    unisonexe := Expand(ReadSetVarFromBatchFile(A_AppDataCommon . "\mobilmir.ru\_unison_get_command.cmd", unisonExecType))
unisonexe := Trim(unisonexe, """ `t")

Loop Files, %unisonexe%\..\..\*.*, DR
{
    If (FileExist(A_LoopFileFullPath "\*.dll")) {
	If (!path)
	    EnvGet path, PATH
	If (!InStr(path, A_LoopFileLongPath))
	    path .= ";" A_LoopFileLongPath
    }
}
If (path)
    EnvSet PATH, %path%

Loop Files, .sync, FR
{
    SyncSource=
    ConfFileParams=
    FileRead configfile, %A_LoopFileFullPath%
    
    Loop Parse, configfile, `n, `r
    {
	If A_Index = 1
	    SyncSource := A_LoopField
	else
	    ConfFileParams .= A_Space . A_LoopField
    }
    
    RunString = "%unisonexe%" unattended -root "%SyncSource%" -root "%A_WorkingDir%\%A_LoopFileDir%" -force "%SyncSource%" -ignore "Path .sync" -ignore "Name desktop.ini" -auto -logfile "%A_ScriptDir%\unison.log" %ConfFileParams%
    Menu Tray, Tip, Syncing %A_LoopFileDir%
    FileAppend `nStarting %RunString% %1%`t…, *
    SetTimer UnhideRun, -30000
    RunWait %RunString% %1%,,%runMode% UseErrorLevel, runPID
    If (ErrorLevel) {
	FileAppend %ErrorLevel% after running «%RunString% %1%», restarting with visible window.`n, %logFile%
	FileAppend error %ErrorLevel%!`, restarting with visible window., *
	Run %comspec% /C "%RunString%",,UseErrorLevel
    } Else {
	FileAppend OK, *
    }
    
    If (FileExist(A_LoopFileDir . "\.aftersync.cmd")) {
	FileAppend `nFound .aftersync.cmd`, verifying…, *
	SetTimer UnhideRun, -30000
	RunWait "%gpgexe%" --verify .aftersync.cmd.sig .aftersync.cmd, %A_LoopFileDir%, %runMode% UseErrorLevel
	If (ErrorLevel) {
	    FileAppend Error %ErrorLevel% verifying .aftersync.cmd.sig in %A_LoopFileDir%`n, %logFile%
	    FileAppend Error %ErrorLevel%!, *
	} Else {
	    FileAppend OK`, starting…, *
	    Run %comspec% /C .aftersync.cmd, %A_LoopFileDir%, %runMode%
	    If (ErrorLevel) {
		FileAppend Error %ErrorLevel% running .aftersync.cmd in %A_LoopFileDir%`n, %logFile%
		FileAppend Error %ErrorLevel%!, *
	    } Else {
		FileAppend OK, *
	    }
	}
    }
    FileAppend `n, *
    
    SetTimer UnhideRun, Off
    Menu Tray, Tip
}
If (FileExist(logFile))
    Run "%logFile%"

Exit

UnhideRun:
    WinShow ahk_pid %runPID%
return
