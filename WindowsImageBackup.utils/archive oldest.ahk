;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

FileEncoding CP1
srcDir = %A_ScriptDir%\..\WindowsImageBackup
compressOptions = -mqs=on -mx=9 -m0=BCJ2 -m1=LZMA2:a=2:fb=273 -m2=LZMA2:d22 -m3=LZMA2:d22 -mb0:1 -mb0s1:2 -mb0s2:3

IgnoreChecksumsForFiles := {"*checksums.md5": 1}

Process Priority,,L
Loop {
    oldestDirDate=
    oldestDirName=
    Loop Files, %srcDir%\*.*, D
    {
	If(!oldestDirDate || A_LoopFileTimeCreated < oldestDirDate) {
	    oldestDirDate := A_LoopFileTimeCreated
	    oldestDirName := A_LoopFileName
	}
    }
    
    If (!oldestDirName)
	break
    
    Loop Files, %srcDir%\%oldestDirName%\*.md5
	If (A_LoopFileSize==0)
	    FileDelete %A_LoopFileFullPath%
    foundError := 0
    newSumsFName := srcDir "\" oldestDirName "-checksums.md5"
    age=-1 ; if stays -1, file does not exist
    Loop Files, %newSumsFName%
    {
	age= ; to substact from A_Now
	age -= A_LoopFileTimeModified, Days
	If (age)
	    FileMove %newSumsFName%, %newSumsFName%.%A_LoopFileTimeModified%
    }
    If (age) ; either checksums not found, or were old
	Runwait %comspec% /C "PUSHD "%srcDir%\%oldestDirName%" & "%A_ScriptDir%\md5sum.exe" -r "*" >"%srcDir%\%oldestDirName%-checksums.md5"", %srcDir%\%oldestDirName%, Min UseErrorLevel
    
    If (FileExist(oldSumsFName := srcDir "\" oldestDirName "\checksums.md5")) {
	newSums := Object()
	Loop Read, %newSumsFName%
	{
	    fName := SplitChecksumLine(A_LoopReadLine, checksum)
	    If (!IgnoreChecksumsForFiles.HasKey(fName))
		newSums[fName] := checksum
	}
	
	Loop Read, %oldSumsFName%
	    If (newSums.HasKey(fName := SplitChecksumLine(A_LoopReadLine, checksum))) {
		If ((newSum := newSums[fName]) <> checksum) {
		    foundError := 1
		    FileAppend new %newSum% : old %A_LoopReadLine%`n, %newSumsFName%-errors.txt
		}
	    }
    } Else {
	FileRead newMD5s, %newSumsFName%
	FileAppend # %A_Now% written anew`, because there were no original checksums.md5`n%newMD5s%, %oldSumsFName%
	newMD5s=
    }
    
    If (foundError) {
	Run "%newSumsFName%-errors.txt"
	MsgBox Контрольные суммы в %oldestDirName% не совпадают!
	ExitApp 
    }
	
    If (A_ComputerName = "IT-Head") {
	dstFPath := "r:\WindowsImageBackup-archives"
    } Else {
	RunWait %comspec% /C "ECHO.|%A_WinDir%\System32\net.exe use \\IT-Head.office0.mobilmir /user:guest0 0"
	RunWait %comspec% /C "ECHO.|%A_WinDir%\System32\net.exe use \\IT-Head /user:guest0 0"
	dstFPath := FirstExisting( "\\IT-Head.office0.mobilmir\Backup\WindowsImageBackup-archives"
			    , "\\IT-Head\Backup\WindowsImageBackup-archives"
			    , A_ScriptDir . "\..\WindowsImageBackup-archives") "\" oldestDirName ".7z"
    }
    dstFPath .=  "\" oldestDirName ".7z"
    
    Try {
	Loop Files, %dstFPath%
	{
	    SplitPath A_LoopFileName, , , OutExtension, OutNameNoExt,
	    FileMove %A_LoopFileFullPath%, % SubStr(A_LoopFileFullPath, 1, -StrLen(A_LoopFileExt)) A_LoopFileTimeModified "." A_LoopFileExt
	}
	runcmd="c:\Program Files\7-Zip\7zG.exe" a %compressOptions% -- "%dstFPath%.tmp"
	RunWait %runcmd%, %srcDir%\%oldestDirName%, Min UseErrorLevel
	If (ErrorLevel) {
	    If (ErrorLevel!=255) { ; 255 User stopped the process
		;1 Warning (Non fatal error(s)). For example, one or more files were locked by some other application, so they were not compressed. 
		;2 Fatal error 
		;7 Command line error 
		;8 Not enough memory for operation 
		MsgBox %runcmd%`nreturned ErrorLevel %ErrorLevel%
	    }
	    ExitApp
	} Else {
	    Try {
		FileMove %dstFPath%.tmp, %dstFPath%
		FileRemoveDir %srcDir%\%oldestDirName%, 1
	    } 
	}
    }
    Sleep 300000
}

MsgBox Finished %A_Now%!

ExitApp

FirstExisting(paths*) {
    for index,path in paths
    {
	IfExist %path%
	    return path
    }
    
    return
}

SplitChecksumLine(ByRef line, ByRef checksum) {
    ; checksum *path or name
    s1 := InStr(line, " ", true)
    checksum := SubStr(A_LoopReadLine, 1, s1-1)
    SplitPath % Trim(SubStr(line, s1+1)), fname
    return fname
}
