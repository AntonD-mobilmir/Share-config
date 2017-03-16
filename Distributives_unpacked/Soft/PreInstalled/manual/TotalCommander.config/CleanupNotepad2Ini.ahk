;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

Loop %0%
{
    outFName := %A_Index%
    out := FileOpen(outFName . ".tmp", "w")
    skipSection := 0
    Loop Read, %1%
    {
	If (RegExMatch(A_LoopReadLine, "S)^\[.+\]$")) { ; Section start
	    skipSection := StartsWith(A_LoopReadLine, "[Recent")
	    ; --- debug --- sectionName := A_LoopReadLine
	}
	
	If (!skipSection)
	    out.Write(A_LoopReadLine . "`n")
    }
    out.Close()
    If (FileExist(outFName))
	FileMove %outFName%, %outFName%.bak, 1
    FileMove %outFName%.tmp, %outFName%, 1
}

Exit

StartsWith(s1, s2) {
    return SubStr(s1, 1, StrLen(s2))=s2
}
