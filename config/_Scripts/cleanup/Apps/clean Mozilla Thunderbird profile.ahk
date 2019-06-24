;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

Global flags

Loop %0% ; for each argument
{
    CurrentArg := %A_Index%
    If (SubStr(CurrentArg, 1, 1) == "/") { ; it's a switch
	StringLower CurrentArg, CurrentArg
	flags .= "," . SubStr(CurrentArg, 2)
	; u = unattended
	; f = force cleaning up even if there are no prefs.js in a dir
	; c = clean up more (completely remove ImapMail, remove all indexes – *.msf)
    } Else { ; otherwise it's dir-path
	fDirInArgs := true
	Loop %CurrentArg%, 2
	    CleanupMTProfile(A_LoopFileFullPath)
    }
}

If (!fDirInArgs) ; if there were no dir-paths in args, process current dir
    CleanupMTProfile(".")

CleanupMTProfile(Dir) {
    backupWorkDir := A_WorkingDir
    Loop %Dir%, 2
    {
	prefsjsExists := cleanMore := false
	IfExist %A_LoopFileFullPath%\prefs.js
	    prefsjsExists := true
	If c in %flags%
	    cleanMore := true
	
	If u in %flags%
	{
	    If f not in %flags%
		If (!prefsjsExists)
		{
		    FileAppend %A_LoopFileFullPath% contains no prefs.js , **
		    continue
		}
	} Else {
	    If f not in %flags%
		If (!prefsjsExists) {
		    MsgBox 3, Mozilla profile cleaner, В %A_LoopFileFullPath% нет файла prefs.js. Всё равно выполнить чистку?
		    IfMsgBox Cancel
			ExitApp
		    IfMsgBox No
			Continue
		}
	    
	    If (!cleanMore) {
		MsgBox 3, Mozilla profile cleaner, Очистка %A_LoopFileFullPath%`n`nУдалить также ImapMail и индексы (*.msf)?
		IfMsgBox Cancel
		    ExitApp
		IfMsgBox Yes
		    cleanMore := true
	    }
	}
	
	SetWorkingDir %A_LoopFileFullPath%
	FileDelete parent.lock
	If (FileExist("parent.lock")) {
	    MsgBox Профиль %A_LoopFileFullPath% занят!
	    Continue
	}
	FileDelete _CACHE_CLEAN_
	FileDelete *.db
	FileDelete *.log
	FileDelete *.mozlz4
	FileDelete *.rdf
	FileDelete *.sqlite
	FileDelete *.sqlite-journal
	FileDelete *.sqlite-shm
	FileDelete *.sqlite-wal
	FileDelete *.tmp
	FileDelete .startup-incomplete
	FileDelete addonStartup.json.lz4
	
	;FileDelete session-*.json
	FileDelete addons.json
	FileDelete AddThisProfile.ahk
	FileDelete AlternateServices.txt
	FileDelete blocklist.xml
	FileDelete blocklist-addons.json
	FileDelete blocklist-gfx.json
	FileDelete blocklist-plugins.json
	FileDelete business_contacts.mab
	FileDelete compatibility.ini
	FileDelete compreg.dat
	FileDelete descript.ion
	FileDelete directoryTree.json
	FileDelete downloads.json
	FileDelete extensions.cache
	FileDelete extensions.ini
	FileDelete extensions.json
	FileDelete extensions.log
	FileDelete extensions-install.txt
	FileDelete folderTree.json
	FileDelete IniFilesUnicode.ahk
	FileDelete IniReadUnicode.ahk
	FileDelete mailViews.dat
	FileDelete panacea.dat
	FileDelete pgprules.xml
	FileDelete pluginreg.dat
	FileDelete prefs.jsr
	FileDelete prefs_AddRarusExchAcc.sed
	FileDelete prefs_BusinessContacts.js
	FileDelete prefs_CommonOnly.js
	FileDelete prefs_RarusExch.js
	FileDelete restore_business_contacts.ahk
	FileDelete revocations.txt
	FileDelete search.json
	FileDelete search-metadata.json
	FileDelete SecurityPreloadState.txt
	FileDelete session.json
	FileDelete sessionCheckpoints.json
	FileDelete ShutdownDuration.json
	FileDelete SiteSecurityServiceState.txt
	FileDelete storage.sdb
	FileDelete Telemetry.ShutdownTime.txt
	FileDelete times.json
	FileDelete tmprules.dat
	FileDelete training.dat
	FileDelete traits.dat
	FileDelete update_Feeds.ahk
	FileDelete update_pgprules.ahk
	FileDelete update_profile.ahk
	FileDelete update_profile.cmd
	FileDelete urlclassifier.pset
	FileDelete user.js
	FileDelete XPC.mfl
	FileDelete xpti.dat
	FileDelete XUL.mfl
	FileDelete xulstore.json
	
	Loop backup_*, 2
	    FileRemoveDir %A_LoopFileFullPath%, 1
	Loop Files, Cache.Trash*, D
	    FileRemoveDir %A_LoopFileFullPath%, 1
	
	FileRemoveDir blocklists, 1
	FileRemoveDir gmp, 1
	FileRemoveDir Cache, 1
	FileRemoveDir ABphotos, 1
	FileRemoveDir crashes, 1
	FileRemoveDir Photos, 1
	FileRemoveDir saved-telemetry-pings, 1
	FileRemoveDir Cache2, 1
	FileRemoveDir extensions, 1
	FileRemoveDir extensions_DisabledByDefault, 1
	FileRemoveDir google_tasks_sync, 1
	FileRemoveDir minidumps, 1
	FileRemoveDir safebrowsing, 1
	FileRemoveDir startupCache, 1
	FileRemoveDir OfflineCache, 1
	FileRemoveDir TestPilotExperimentFiles, 1
	FileRemoveDir .clipbak, 1
	FileRemoveDir datareporting, 1
	
	FileDelete gnupg\*.cmd
	FileDelete gnupg\*.ahk
	FileDelete gnupg\*.lock
	FileDelete gnupg\gpg-agent.conf
	FileDelete gnupg\random_seed
	FileDelete gnupg\trust.asc
	FileDelete gnupg\0xE91EA97A.asc
	
	IfNotExist calendar-data\local.sqlite
	    FileRemoveDir calendar-data, 1
	
	Loop Mail\*.mozmsgs, 2, 1 ; Removing Windows Search index-helpers
	{
;	    If (A_LoopFileExt = "mozmsgs") ; implied in Loop mask
	    FileDelete %A_LoopFileFullPath%\*.wdseml
	    FileRemoveDir %A_LoopFileFullPath%
	}
	
	Loop Mail\*, 0, 1
	    If (A_LoopFileSize=0) {
		IfNotExist %A_LoopFileFullPath%.sbd\*
		{
		    FileDelete %A_LoopFileFullPath%
		    FileRemoveDir %A_LoopFileFullPath%.sbd
		}
		If (!cleanMore)
		    FileDelete %A_LoopFileFullPath%.msf
	    }
	
	If (cleanMore) {
	    FileDelete virtualFolders.dat
            FileDelete virtualFolders-1.dat
	    FileRemoveDir ImapMail, 1
	    Loop Mail\*.msf, 0, 1
		FileDelete %A_LoopFileFullPath%
	    Loop Mail\msgFilterRules.dat, 0, 1
		If (A_LoopFileSize=27)
		    FileDelete %A_LoopFileFullPath%
		    
	} Else {
	    Loop ImapMail\*.mozmsgs, 2, 1 ; Removing Windows Search index-helpers
	    {
		FileDelete %A_LoopFileFullPath%\*.wdseml
		FileRemoveDir %A_LoopFileFullPath%
	    }
	}
    }
    SetWorkingDir %backupWorkDir%
}
