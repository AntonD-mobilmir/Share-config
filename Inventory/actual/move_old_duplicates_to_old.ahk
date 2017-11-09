#NoEnv

Suffix = .7z
SuffixLen := StrLen(Suffix)

Loop Files, *, DR ; Dirs only, recursively
{
    NameList=
    Loop %A_LoopFileFullPath%\*%Suffix%
    {
    ;    SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
	NameList .= SubStr(A_LoopFileName, 1, -SuffixLen) . "`n"
    }
    Sort NameList
    Loop Parse, NameList, `n
    {
	If ( Before1stSpace(A_LoopField) = Before1stSpace(PrevName) ) {
	    try {
		IfNotExist ..\old\%A_LoopFileFullPath%
		    FileCreateDir ..\old\%A_LoopFileFullPath%
		FileMove %A_LoopFileFullPath%\%PrevName%.7z, ..\old\%A_LoopFileFullPath%\%PrevName%.7z
	    } catch e {
;		MsgBox % e.Message . " in " . e.What . " (Line# " . e.Line . ")`n" . "Extra: " . e.Extra
		log(e.Message . " in " . e.What . " (Line# " . e.Line . ")`n" . "Extra: " . e.Extra)
	    }
	}
	PrevName = %A_LoopField%
    }
}

Before1stSpace(str) {
    return SubStr(str, 1, InStr(str, " ")-1)
}

log(text) {
    FileAppend %text%`n, *, cp1
    FileAppend %text%`n, %A_Temp%\%A_ScriptName%.log
}
