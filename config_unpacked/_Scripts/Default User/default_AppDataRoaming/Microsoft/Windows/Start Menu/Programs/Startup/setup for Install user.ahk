;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

If (A_UserName!="Install") {
    If (A_ScriptDir=A_Startup)
	FileDelete %A_ScriptFullPath%
    ExitApp
}

Sleep 1000

ConfigPathsList=
(
\\Srv0.office0.mobilmir\profiles$\Share\config
\\192.168.1.80\profiles$\Share\config
D:\Distributives\config
)

Loop Parse, ConfigPathsList, `n
    If (FileExist(A_LoopField)) {
	ConfigPath:=A_LoopField
	break
    }

If (!ConfigPath) {
    EnvGet SystemDrive,SystemDrive
    getDefaultconfigScript := FirstExisting(A_AppDataCommon . "\mobilmir.ru\_get_defaultconfig_source.cmd", SystemDrive . "\Local_Scripts\_get_defaultconfig_source.cmd")
    
    If (getDefaultconfigScript) {
	DefaultsPath:=ReadSetVarFromBatchFile(getDefaultconfigScript, "DefaultsSource")
	SplitPath DefaultsPath,,ConfigPath
    }
}

If (ConfigPath)
    Run %comspec% /C "%ConfigPath%\_Scripts\AddUsers\AddUser_Install.cmd", %A_Temp%, Min
Else
    Throw "ConfigPath not found"

ExitApp

ReadSetVarFromBatchFile(filename, varname) {
    Loop Read, %filename%
    {
	trimmedReadLine:=Trim(A_LoopReadLine)
	If (RegExMatch(trimmedReadLine, "i)SET[:space:]+(?P<Name>.+)[:space:]*=(?P<Value>.+)", match)) {
	    If (Trim(Trim(matchName), """") = varname) {
		return Trim(Trim(matchValue), """")
	    }
	}
    }
}

FirstExisting(paths*) {
    for index,path in paths
    {
	IfExist %path%
	    return path
    }
    
    return ""
}
