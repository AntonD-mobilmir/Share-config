;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

FindThunderbirdProfile() {
    Encodings=UTF-8 UTF-16 CP1251

    profilesini=%A_AppData%\Thunderbird\profiles.ini

    Loop Parse, Encodings, %A_Space%
    {
	FileEncoding %A_LoopField%
	Loop Read, %profilesini%
	{
	    If (RegExMatch(Trim(A_LoopReadLine), "^\[Profile[0-9]+\]$")) {
		ProfileName:=SubStr(A_LoopReadLine, 2, -1)
		ProfilePathIsRelative=0
		Try {
		    ProfilePath := IniReadUnicode(profilesini,ProfileName,"Path")
		    ProfilePathIsRelative := IniReadUnicode(profilesini,ProfileName,"IsRelative")
		} catch
		    continue
		
		If ProfilePathIsRelative
		    ProfilePath = %A_AppData%\Thunderbird\%ProfilePath%
		
		ProfileDefault=0
		IfExist %ProfilePath%\prefs.js
		{
		    LastFoundProfilePath=%ProfilePath%
		    Try {
			ProfileDefault := IniReadUnicode(profilesini,ProfileName,"Default")
			If ProfileDefault
			    return %ProfilePath%
		    }
		}
	    }
	}
    }
    
    If LastFoundProfilePath
	return LastFoundProfilePath
    Else
	Throw Exception("Профиль не найден", -1, "Ни одна из папок профилей, прочитанных из profiles.ini, не содержит prefs.js")
}

SelectMTProfileFolder(mtProfileDir, showDialogueBeforeChecking:=0) {
    If (!mtProfileDir) {
	EnvGet UserProfile, USERPROFILE
	mtProfileDir = %UserProfile%\Mail\Thunderbird\profile
    }
    While ((A_Index==1 && showDialogueBeforeChecking) || (!FileExist(mtProfileDir . "\prefs.js") && reason:=" (в папке должен быть prefs.js)" )) {
	FileSelectFolder mtProfileDir, *%mtProfileDir%, 2, Укажите путь к профилю Thunderbird%reason%
	If (!mtProfileDir)
	    Throw "Выбор папки отменён пользователем"
    }
    return mtProfileDir
}

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    mtProfileDir := FindThunderbirdProfile()
    EnvGet Unattended, Unattended
    If (!Unattended) {
        EnvGet RunInteractiveInstalls, RunInteractiveInstalls
        Unattended := RunInteractiveInstalls == "0"
    }
    If (Unattended) {
        ExitApp 1
    } Else {
	If (!mtProfileDir) {
	    EnvGet UserProfile, USERPROFILE
	    mtProfileDir = %UserProfile%\Mail\Thunderbird\profile
	}
	mtProfileDir := SelectMTProfileFolder(mtProfileDir)
    }
    
    FileAppend %mtProfileDir%`n, *, cp1
    ExitApp
}

#Include <IniFilesUnicode>
