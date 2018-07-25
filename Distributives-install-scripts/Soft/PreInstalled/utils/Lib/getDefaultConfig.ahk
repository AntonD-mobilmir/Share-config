;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

getDefaultConfigFileName(defCfg := -1) {
    If (defCfg==-1)
	defCfg := getDefaultConfig()
    SplitPath defCfg, OutFileName
    return OutFileName
}

getDefaultConfigDir(defCfg := -1) {
    If (defCfg==-1) {
        EnvGet configDir, configDir
	If (configDir)
	    return RTrim(configDir, "\")
	defCfg := getDefaultConfig()
    }
    SplitPath defCfg,,OutDir
    return OutDir
}

getDefaultConfig(batchPath := -1) {
    If (batchPath == -1) {
	EnvGet DefaultsSource, DefaultsSource
	If (DefaultsSource)
	    return DefaultsSource
	Try {
	    return getDefaultConfig(A_AppDataCommon . "\mobilmir.ru\_get_defaultconfig_source.cmd")
	}
	EnvGet SystemDrive, SystemDrive
	return getDefaultConfig(SystemDrive . "\Local_Scripts\_get_defaultconfig_source.cmd")
    } Else {
	return ReadSetVarFromBatchFile(batchPath, "DefaultsSource")
    }
}

#Include %A_LineFile%\..\ReadSetVarFromBatchFile.ahk
