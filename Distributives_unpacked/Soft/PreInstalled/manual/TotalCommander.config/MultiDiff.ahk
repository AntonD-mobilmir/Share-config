;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

diffProg = "%A_ScriptDir%\..\KDiff3\kdiff3.exe"

files := Object()
filesNotFound := ""

Loop %0%
{
    arg:=Trim(%A_Index%, """ `t")
    If (attr := FileExist(arg)) {
	If (!InStr(attr, "D")) {
	    files.Push("""" . arg . """")
	}
    } Else {
	filesNotFound .= "`n" . arg
    }
}

filesCount := files.Length()
If (filesCount==2) { ; only 2-way diff
    Run % diffProg . " " . files[1] . " " . files[2]
} Else { ; first file is base (3rd arg in KDiff3), others are compared between themselves and the base
    If (!(filesCount & 1)) { ; number is odd
	; compare in pairs : 1:2, 3:4 etc
	For i,v in files {
	    If (A_Index & 1) { ; index is even: 1 3 5 …
		pairFile := v
	    } Else { ; index is odd: 2 4 6 …
		Run % diffProg . " " . pairFile . " " . v
	    }
	}
    } Else {
	; i=1	first file is base
	; i=2	used in first pair-comparison, nothing alone
	; i=3	compare 3:2:1
	; i=4	compare 4:3:1
	; etc
	For i,v in files {
	    If (A_Index==1) {
		baseFile := v
	    } Else {
		If (A_Index & 1) { ; index is even : (1 skipped) 3 5 7 …
		    Run % diffProg . " " . pairFile . " " . v . " " . baseFile
		} Else { ; index is odd
		    pairFile := v
		}
	    }
	}
    }
}

If (filesNotFound)
    MsgBox Files not found:%filesNotFound%
