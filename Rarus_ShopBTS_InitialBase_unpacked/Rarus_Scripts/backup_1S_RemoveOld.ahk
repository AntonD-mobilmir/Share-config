;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

global destdir

Try {
    destDir=%1%
    If (!destDir)
	EnvGet destdir, destdir
    If !destdir
	throw ("%destdir% not defined!")

    ;SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
    SplitPath destdir,,,,,destdrive

    FileDelete %destdir%\*.tmp
    For i, ext in ["7z", "zpaq"] {
	maxSize%ext% := 0
	Loop Files, %destdir%\*.7z
	{
	    If (maxSize%ext% < A_LoopFileSizeMB)
		maxSize%ext% := A_LoopFileSizeMB
	    backupArchivesList .= A_LoopFileTimeModified . A_Tab . A_LoopFileName "`n"
	}
    }
    
    If (!maxSize7z && !maxSizezpaq)
	Throw ("In destdir, no files with size > 0")

    Sort backupArchivesList, C

    DriveGet BackupsDriveSize, Capacity, %destdrive%\
    freespaceMin := Max(100, BackupsDriveSize // 10, maxSize7z * 30, maxSizezpaq*2)
    DriveSpaceFree freespaceAvail, %dedstdrive%\
    ; if free space is less than 100M, 10% of drive size or 30x maxSize7z or 2x maxSizezpaq, remove, until free space is at least 2x of that value
    If (freespaceAvail < freespaceMin) {
	freespaceMin *= 2
	Loop 100
	{
	    ; If there's no more differential backups to delete (considering bottom age limit), remove any other backups, starting from oldest
	    DeleteOldestBackup(backupArchivesList, "^ShopBTS_\d{4}-\d{2}-\d{2}\.7z$") || DeleteOldestBackup(backupArchivesList, "^ShopBTS_.*\.7z$") || DeleteOldestBackup(backupArchivesList) || Throw "Found no files to delete"
	    DriveSpaceFree freespaceAvail, %dedstdrive%\
	} Until freespaceAvail >= freespaceMin
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
	    FileAppend Removed %nameFile% (regex %RegExpMask%`, date %dateFile%)`n, *
	    return 1
	}
    }
    
    return 0 ; No matching files to remove
}
