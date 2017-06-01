#NoEnv
#SingleInstance ignore
logFile=%A_Temp%\%A_ScriptName%.%A_Now%.log
EnvGet LocalAppData, LOCALAPPDATA
If (!(gpgexe:=findexe("gpg.exe", "c:\SysUtils\gnupg\pub", LocalAppData . "\Programs\SysUtils\gnupg\pub"))) {
    FileAppend gpg.exe not found!`n, %logFile%
}

arg1=%1%
If (arg1="-batch") {
    runMode=Min
    unisonExecType=unisontext
} Else {
    unisonExecType=unisongui
}

EnvGet unisonexe, %unisonExecType%
If (!unisonexe)
    unisonexe := Expand(ReadSetVarFromBatchFile(A_AppDataCommon . "\mobilmir.ru\_unison_get_command.cmd", unisonExecType))

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
    Menu Tray, Tip, %RunString%
    RunWait %RunString% %1%,,%runMode% UseErrorLevel
    If (ErrorLevel) {
	FileAppend %ErrorLevel% after running «%RunString% %1%».`n, %logFile%
	Run %comspec% /C "%RunString%",,UseErrorLevel
	If (ErrorLevel)
	    FileAppend ErrorLevel %ErrorLevel%%A_Space%, %logFile%
	FileAppend Starting «%RunString%» in background.`n, %logFile%
    }
    
    If (FileExist(A_LoopFileDir . "\.aftersync.cmd")) {
	RunWait "%gpgexe%" --verify .aftersync.cmd.sig .aftersync.cmd, %A_LoopFileDir%, Min UseErrorLevel
	If (ErrorLevel) {
	    FileAppend Error %ErrorLevel% verifying .aftersync.cmd.sig in %A_LoopFileDir%`n, %logFile%
	} Else {
	    Run %comspec% /C .aftersync.cmd, %A_LoopFileDir%, Min
	}
    }
    
    Menu Tray, Tip
}
If (FileExist(logFile))
    Run "%logFile%"

Exit
