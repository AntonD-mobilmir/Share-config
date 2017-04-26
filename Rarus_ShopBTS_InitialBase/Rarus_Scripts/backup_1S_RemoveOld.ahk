;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

global MaxSize=0, BackupArchivesList, destdir
Try {
    EnvGet destdir, destdir

    If !destdir
	throw ("%destdir% not defined!")

    ;SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
    SplitPath destdir,,,,,destdrive

    FileDelete %destdir%\*.tmp
    Loop %destdir%\*
    {
	If (MaxSize < A_LoopFileSizeMB)
	    MaxSize:=A_LoopFileSizeMB
	BackupArchivesList .= A_LoopFileTimeModified . A_Tab . A_LoopFileName "`n"
    }
    
    If !MaxSize
	Throw ("In destdir, no files with size > 0")

    Sort BackupArchivesList, C

    Loop
    {
	DriveSpaceFree BackupsFreeSpace, %destdrive%\
	; if free space is less than 100M or 10x MaxSize, remove, until free space is at least 20x
	If ( BackupsFreeSpace < 100 || BackupsFreeSpace < (MaxSize * 10) )
	{
    ;	MsgBox % BackupsFreeSpace ", " BackupsFreeSpace " / " MaxSize " = " BackupsFreeSpace / MaxSize
	    DeleteOldestBackup("ShopBTS_[0-9]{4}_[0-9]{2}_[0-9]{2}\.7z")
	    DeleteOldestBackup("ShopBTS_[0-9]{4}-[0-9]{2}-[0-9]{2}\.7z")
	    If ErrorLevel ; If there's no more differential backups to delete (considering bottom age limit)
		DeleteOldestBackup() ; remove any other backups, starting from oldest
	    continue
	}
	break
    }
} catch e {
    FileAppend % "[" . e . "] " . e.File . " (" . e.Line . "): " . e.What . " " . e.Message . " (" . e.Extra . ")" , *
}

Exit

; remove old archives
; not newer than 2 months
DeleteOldestBackup(RegExpMask="", AgeLimit=60) {
    Loop Parse, BackupArchivesList, `n
    {
	FileName := SubStr(A_LoopField, InStr(A_LoopField, A_Tab, true)+1)
	If (RegExMatch(FileName,RegExpMask))
	    IfExist %destdir%\%FileName%
	    {
		FileDate := SubStr(A_LoopField, 1, InStr(A_LoopField, A_Tab, true))
		FileAppend %FileName% matched regex %RegExpMask%`, date %FileDate%`, will be removed, *
		
		FileDelete %destdir%\%FileName%
		;quit probably infinite cycle, if file can't be deleted
		If ErrorLevel ; ErrorLevel is set to the number of files that failed to be deleted (if any) or 0 otherwise
		    throw ("Error deleting """ destdir "\" FileName """" )
		return
	    } Else {
		return 
	    }
    }
    
    ErrorLevel = 1 ; No matching files to remove
}
