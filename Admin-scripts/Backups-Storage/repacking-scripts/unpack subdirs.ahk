;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

global logFile, extractExtensions, pidProcUnhide
EnvGet logFile,logFile
If (!logFile)
    logFile = %A_ScriptDir%\..\logs\%A_ScriptName% %A_Now%.log
extractExtensions = 7z,xz,zip,gz,gzip,tgz,bz2,bzip2,tbz2,tbz,tar,lzma,rar,cab,arj,z,taz,lzh,lha,xar

Loop %0%
    UnpackArchives(%A_Index%)
Log(". End")
Exit

UnpackArchives(path) {
    Log(". Upacking all " . extractExtensions . " from", path)
    TrayTip Unpack all archives, processing %path%.
    Loop %path%\*,0,1	; Loop files in all subdirs
    {
	If A_LoopFileExt in bak,old,lock
	    FileDelete %A_LoopFileFullPath%
	If A_LoopFileExt in %extractExtensions%
	{
	    outputDir=%A_LoopFileFullPath%._
	    IfExist %outputDir%
		Log("* Both archive and unpack dir exist for", A_LoopFileFullPath)
	    Else {
		SetTimer ShowArchiverWindow, -5000
		RunWait "%A_ProgramFiles%\7-Zip\7z.exe" x -aoa -y -p- -o"%outputDir%" -- "%A_LoopFileFullPath%",%A_LoopFileDir%, Hide UseErrorLevel, pidProcUnhide
		SetTimer ShowArchiverWindow, Off
		If ErrorLevel
		    Log("! Error " . ErrorLevel . " extracting from", A_LoopFileFullPath)
		Else {
		    Log(". succesfull extraction, removing", A_LoopFileFullPath)
		    FileDelete %A_LoopFileFullPath%
		    If ErrorLevel
			Log("* Cannot delete archive", A_LoopFileFullPath)
		    UnpackArchives(outputDir)
		}
	    }
	; } Else If A_LoopFileExt in odb,odg,odp,otp,ots,ott,ods,odt,docx,pptx,xlsx 
	} Else If (FileIsZip(A_LoopFileFullPath)) {
	    SetTimer ShowArchiverWindow, -10000
	    RunWait %comspec% /C ""`%ProgramData`%\mobilmir.ru\Common_Scripts\zip_store.cmd" /NK "%A_LoopFileFullPath%"", %A_LoopFileDir%, Hide UseErrorLevel, pidProcUnhide
	    SetTimer ShowArchiverWindow, Off
	    If ErrorLevel
		Log("! Error " . ErrorLevel . " repacking", A_LoopFileFullPath)
	    Else {
		FileGetSize newSize, %A_LoopFileFullPath%
		If (newSize < A_LoopFileSize * 1.05) {
		    FileMove %A_LoopFileFullPath%.bak, %A_LoopFileFullPath%, 1
		    If ErrorLevel
			Log("* Cannot restore backup", A_LoopFileFullPath . ".bak")
		} Else {
		    Log(". succesfull repack (from " . A_LoopFileSize . " to " . newSize . ")", A_LoopFileFullPath)
		    FileDelete %A_LoopFileFullPath%.bak
		    If ErrorLevel
			Log("* Cannot delete backup", A_LoopFileFullPath)
		}
	    }
	}
    }
    TrayTip
}

ShowArchiverWindow:
    WinShow ahk_pid %pidProcUnhide%
return

Log(msgText, quotedPath="") {
    global logFile
    If quotedPath
	msgText = %msgText% "%quotedPath%"
    FileAppend %msgText%`n`r,*, CP866
    FileAppend %A_Now% %msgText%`n,%logFile%
}

FileIsZip(filename) {
    SplitPath filename, , , OutExtension
    If OutExtension in xls,doc,pdf,eml,txt,jpg,asc,png,ppt,lnk,gif,mm,pfx,rtf,htm,jpeg,html,js,tif,css,gpg,ai,wav,ico,amr,lock,cmd,url,mp3,htc,eps,svg,mp4,DS_Store,wbk,php,csv,3gp,exe,dll,xml,xlt,sxw,reg,pps,lic,dat,bmp,swf,ahk,tx,tsv
	return false
    FileRead magicbytes, *P0 *m2 %filename%
    If (magicbytes == "PK")
	return true
    Else
	return false
}
