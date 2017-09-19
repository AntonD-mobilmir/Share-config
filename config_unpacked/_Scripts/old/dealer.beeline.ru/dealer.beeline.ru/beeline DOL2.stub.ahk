#NoEnv
#SingleInstance force

EnvGet configDir, configDir
If (!configDir)
    configDir := getDefaultConfigDir()
;"https://www.dropbox.com/sh/v0c4jw6n26p259u/AAC8w2B9ksXnKdqcoc_RZmURa/dealer.beeline.ru/beeline%20DOL2.gpg?dl=1"
scriptUpdateAhk := configDir "\_Scripts\scriptUpdater.ahk"
If(FileExist(scriptUpdateAhk)) {
    Progress A ZH0, Скачивание актуального скрипта запуска
    WinSet AlwaysOnTop, Off, 
    RunWait "%A_AhkPath%" "%scriptUpdateAhk%" "%A_ScriptFullPath%",,UseErrorLevel
    Reload
} Else {
    MsgBox Этот скрипт – просто заглушка для скачивания актуального скрипта запуска. Но scriptUpdater.ahk недоступен :(
}
ExitApp

;getDefaultConfig.ahk
getDefaultConfig() {
    defaultConfig := ReadSetVarFromBatchFile(A_AppDataCommon . "\mobilmir.ru\_get_defaultconfig_source.cmd", "DefaultsSource")
    If (!defaultConfig) {
	EnvGet SystemDrive, SystemDrive
	defaultConfig := ReadSetVarFromBatchFile(SystemDrive . "\Local_Scripts\_get_defaultconfig_source.cmd", "DefaultsSource")
    }
    return defaultConfig
}

getDefaultConfigFileName() {
    defaultConfig := getDefaultConfig()
    SplitPath defaultConfig, OutFileName
    return OutFileName
}

getDefaultConfigDir() {
    defaultConfig := getDefaultConfig()
    SplitPath defaultConfig,,OutDir
    return OutDir
}

;ReadSetVarFromBatchFile.ahk
ReadSetVarFromBatchFile(filename, varname) {
    Loop Read, %filename%
    {
	If (mpos := RegExMatch(A_LoopReadLine, "i)SET\s+(?P<Name>.+)\s*=(?P<Value>.+)", match)) {
	    If (Trim(Trim(matchName), """") = varname) {
		return Trim(Trim(matchValue), """")
	    }
	}
    }
}
