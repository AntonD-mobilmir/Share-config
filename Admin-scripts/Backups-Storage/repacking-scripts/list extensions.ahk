#NoEnv

extlist := Object()
lim = 0
step = 10000

Loop *,0,1
{
    If (A_LoopFileExt) {
	currv := extlist[A_LoopFileExt]
	If (currv) {
	    extlist[A_LoopFileExt] := currv + 1
	} Else {
	    extlist[A_LoopFileExt] := 1
	}
    }
    
    If (A_Index > lim) {
	TrayTip,, processed %A_Index% files.`nLast: %A_LoopFileFullPath%
	lim += step
    }
}

For Key, Value in extlist {
    text .= value A_Tab key "`n"
}

FileAppend %text%, %A_ScriptName%.out.txt
Run "%A_ScriptName%.out.txt"
