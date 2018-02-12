;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

global destdir
destDir=%1%
If (!destDir)
    EnvGet destdir, destdir

Try {

    If !destdir
	throw ("%destdir% not defined!")

    ;SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
    SplitPath destdir,,,,,destdrive

    FileDelete %destdir%\*.tmp
    Loop %destdir%\*
    {
	If (MaxSize < A_LoopFileSizeMB)
	    MaxSize:=A_LoopFileSizeMB
	backupArchivesList .= A_LoopFileTimeModified . A_Tab . A_LoopFileName "`n"
    }
    
    If !MaxSize
	Throw ("In destdir, no files with size > 0")

    Sort backupArchivesList, C

    Loop 100
    {
	DriveSpaceFree BackupsFreeSpace, %destdrive%\
	; if free space is less than 100M or 10x MaxSize, remove, until free space is at least 20x
	If ( BackupsFreeSpace < 100 || BackupsFreeSpace < (MaxSize * 10) )
	{
	    ; MsgBox % BackupsFreeSpace ", " BackupsFreeSpace " / " MaxSize " = " BackupsFreeSpace / MaxSize
	    ; If there's no more differential backups to delete (considering bottom age limit), remove any other backups, starting from oldest
	    DeleteOldestBackup(backupArchivesList, "ShopBTS_[0-9]{4}-[0-9]{2}-[0-9]{2}\.7z") || DeleteOldestBackup(backupArchivesList) || Throw "Found no files to delete"
	    continue
	}
	break
    }
} catch e {
    FileAppend % "[" . e . "] " . e.File . " (" . e.Line . "): " . e.What . " " . e.Message . " (" . e.Extra . ")" , *
}

ExitApp

; remove old archives
; not newer than 2 months
DeleteOldestBackup(ByRef backupArchivesList, RegExpMask="", ageLimit=60) {
    dateLimit += -ageLimit, Days
    Loop Parse, backupArchivesList, `n
    {
	tabPos := InStr(A_LoopField, A_Tab, true)
	dateFile := SubStr(A_LoopField, 1, tabPos-1)
	nameFile := SubStr(A_LoopField, tabPos+1)
	If (dateFile < dateLimit && nameFile ~= RegExpMask && FileExist(destdir "\" nameFile)) {
	    FileDelete %destdir%\%nameFile%
	    
	    ;quit probably infinite cycle, if file can't be deleted
	    If (ErrorLevel) ; ErrorLevel is set to the number of files that failed to be deleted (if any) or 0 otherwise
		throw ("Error deleting """ destdir "\" nameFile """" )
	    FileAppend Removed %nameFile% matched regex %RegExpMask%`, date %dateFile%`n, *
	    return 1
	}
    }
    
    return 0 ; No matching files to remove
}
