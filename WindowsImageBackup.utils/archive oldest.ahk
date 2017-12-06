;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

FileEncoding CP1
srcDir = %A_ScriptDir%\..\WindowsImageBackup
exe7z := TryInvokeFunc("find7zexe","find7zaexe")
If (!exe7z)
    exe7z := A_ProgramFiles "\7-Zip\7z.exe"
If (!FileExist(exe7z))
    Throw Exception("7-Zip не найден")
guiexe7z := TryInvokeFunc("find7zGUIorAny")
If (!guiexe7z && !FileExist(guiexe7z := A_ProgramFiles "\7-Zip\7zG.exe"))
    guiexe7z := exe7z
compressOptions = -mqs=on -mx=9 -m0=BCJ2 -m1=LZMA2:a=2:fb=273 -m2=LZMA2:d22 -m3=LZMA2:d22 -mb0:1 -mb0s1:2 -mb0s2:3

ChecksumTypes := {"7zchecksums.txt": 0, "checksums.md5": 1}
checksumExcludes=
For fname in ChecksumTypes
    checksumExcludes .= "-x!""" fname """"

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
    
    newSumsPath := srcDir "\" oldestDirName "-7zchecksums.txt"
    newSumsErrors := srcDir "\" oldestDirName "-errors.txt"
    Loop Files, %srcDir%\%oldestDirName%\*.md5
	If (A_LoopFileSize==0)
	    FileDelete %A_LoopFileFullPath%
    foundError := 0
    age=0xFFFF ; if stays, sums does not exist
    For fNameSums, type in ChecksumTypes {
	Loop Files, %srcDir%\%oldestDirName%-%fNameSums%
	{
	    age2= ; to substact from A_Now
	    age2 -= A_LoopFileTimeModified, Days
	    If (age2 < age) {
		age := age2
		oldSumsPath = %A_LoopFileLongPath%.%A_LoopFileTimeModified%
		oldSumsType := type
		FileMove %A_LoopFileLongPath%, %oldSumsPath%
	    }
	}
	If (age) {
	    Loop Files, %srcDir%\%oldestDirName%\%fNameSums%
	    {
		age2=
		age2 -= A_LoopFileTimeModified, Days
		If (age2 < age) {
		    age := age2
		    oldSumsPath = %A_LoopFileLongPath%
		    oldSumsType := type
		}
	    }
	}
    } Until !age
    
    If (age) { ; either checksums not found, or were old. Recalc.
	Run %comspec% /C "PUSHD "%srcDir%\%oldestDirName%" && "%exe7z%" h -sccUTF-8 -scrc* -r %checksumExcludes% * >"%srcDir%\%oldestDirName%-7zchecksums.new" 2>&1 && REN "%srcDir%\%oldestDirName%-7zchecksums.new" "*.txt"", %srcDir%\%oldestDirName%, Min UseErrorLevel, pid7z
	If (oldSumsType)
	    Run %comspec% /C "PUSHD "%srcDir%\%oldestDirName%" && "%A_ScriptDir%\md5sum.exe" -r * >"%srcDir%\%oldestDirName%-checksums.new" 2>&1 && REN "%srcDir%\%oldestDirName%-checksums.new" "*.md5"", %srcDir%\%oldestDirName%, Min UseErrorLevel, pidmd5sum
    }
    
    watchPIDs := [pid7z, pidmd5sum]
    Loop
    {
	Sleep 1000
	found=
	For i, PID in watchPIDs {
	    If (PID) {
		Process Exist, %PID%
		If (ErrorLevel && ++found) ; ++found only if ErrorLevel
		    continue
	    }
	    watchPIDs.Delete(i)
	}
    } Until !found
    MsgBox age: %age%`nage2: %age2%`noldSumsType: %oldSumsType%
    
    If (oldSumsPath) {
	If (oldSumsType==1) { ; MD5
	    newSums := Object()
	    Loop Read, %srcDir%\%oldestDirName%-checksums.md5
	    {
		fName := SplitChecksumLine(A_LoopReadLine, checksum)
		If (!(ChecksumTypes.HasKey(fName) || ChecksumTypes.HasKey("*" . fName)))
		    newSums[fName] := checksum
	    }
	    
	    Loop Read, %oldSumsPath%
		If (newSums.HasKey(fName := SplitChecksumLine(A_LoopReadLine, checksum)))
		    If ((newSum := newSums[fName]) <> checksum)
			FileAppend new %newSum% : old %A_LoopReadLine%`n, %newSumsErrors%
	} Else {
	    colMap=
	    ;Read7zHashOut(path, ByRef colTitles := "", ByRef colStarts := "", ByRef colWidths := "")
	    oldHashesR := Read7zHashOut(oldSumsPath, oldTitles)
	    oldTitleIdx := []
	    For i, oldTitle in oldTitles
		oldTitleIdx[oldTitle] := i
	    oldNameCol := i ; last column in titles
	    oldHashes := {}
	    For i, oldHash in oldHashesR
		oldHashes[oldHash[oldNameCol]] := oldHash
	    oldHashesR=
	    
	    For i, newHash in Read7zHashOut(srcDir "\" oldestDirName "-7zchecksums.txt", newTitles) {
		If (!IsObject(colMap)) {
		    colMap := []
		    For i, title in newTitles
			If (oldTitleIdx.HasKey(title))
			    colMap[i] := oldTitleIdx[title]
		    newNameCol := i
		    If (!colMap.Length())
			Throw Exception("Среди хэшей, рассчитываемых 7-Zip, нет хэшей, записанных в файл",, oldSumsPath "`nСтарые хэши: " ObjectToText(oldTitles) "`nНовые хэши: " ObjectToText(newTitles))
		}
		For newCol, oldCol in colMap
		    If (newHash[newCol] != oldHashes[newHash[newNameCol]][oldCol])
			FileAppend % newHash[newNameCol] " mismatched " oldTitles[oldCol] ": old " oldHashes[newHash[newNameCol]][oldCol] ", new " newHash[newCol] "`n", %newSumsErrors%
	    }
	}
    }
    
    If (FileExist(newSumsErrors)) {
	Run "%newSumsErrors%"
	MsgBox При проверке контрольных сумм "%oldestDirName%" обнаружены ошибки!
	ExitApp
    } Else If (!FileExist(imgcopySums := srcDir "\" oldestDirName "\7zchecksums.txt")) {
	FileCopy %srcDir%\%oldestDirName%-7zchecksums.txt, %imgcopySums%
	If (ErrorLevel)
	    errText=Ошибка при копировании файла контрольных сумм
	Else If (!FileExist(imgcopySums))
	    errText=Файл контрольных сумм не скопировался
	If (errText)
	    Throw Exception(errText,, "#" ErrorLevel " """ imgcopySums """")
	Else
	    FileAppend `n# %A_Now% written anew`, because there were no 7zchecksums.txt with image`n, %imgcopySums%
    }
    
    If (A_ComputerName = "IT-Head") {
	dstFPath := "r:\WindowsImageBackup-archives"
    } Else {
	RunWait %comspec% /C "ECHO.|%A_WinDir%\System32\net.exe use \\IT-Head.office0.mobilmir /user:guest0 0"
	RunWait %comspec% /C "ECHO.|%A_WinDir%\System32\net.exe use \\IT-Head /user:guest0 0"
	dstFPath := FirstExisting( "\\IT-Head.office0.mobilmir\Backup\WindowsImageBackup-archives"
				 , "\\IT-Head\Backup\WindowsImageBackup-archives"
				 , A_ScriptDir "\..\WindowsImageBackup-archives")
    }
    dstFPath .=  "\" oldestDirName ".7z"
    
    Try {
	Loop Files, %dstFPath%
	{
	    SplitPath A_LoopFileName, , , OutExtension, OutNameNoExt,
	    FileMove %A_LoopFileFullPath%, % SubStr(A_LoopFileFullPath, 1, -StrLen(A_LoopFileExt)) A_LoopFileTimeModified "." A_LoopFileExt
	}
	runcmd="%guiexe7z%" a %compressOptions% -- "%dstFPath%.tmp"
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

ObjectToText(obj) {
    out := ""
    For i,v in obj
	out .= i ": " ( IsObject(v) ? "{" ObjectToText(v) "}" : (InStr(v, ",") ? """" v """" : v) ) ", "
    return Trim(out, ", ")
}

TryInvokeFunc(fnNames*) {
    local i,fnName
    For i,fnName in fnNames
	If(IsFunc(fnName))
	    Try return %fnName%()
}

#include *i <find7zexe>
