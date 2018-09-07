;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

ParseCommandLine(ByRef commandLine, ByRef delim := "") {
    ; splits array, where some of tokens may be (partially) quoted
    If (delim == "")
        delim := A_Space . A_Tab ; default token delimeters
    
    cmdlArgs := Object()
    , separators := IsByRef(delim) ? Object() : ""
    , argNo := 0, inQuote := false, currFragmentEnd := 1
    Loop Parse, commandLine, %delim%
    {
	If (!inQuote)
	    currArgStart := currFragmentEnd
	currFragmentEnd += StrLen(A_LoopField)+1
	
	Loop Parse, A_LoopField, "
	    If (A_Index>1) ; for «"string"», first loop field is empty. If string is at EOL, last field also is.
		inQuote := !inQuote
	
	If (!inQuote) { ; this substring is not part of quote (starting at currArgStart), or the quote has just ended
            cmdlArgs[argNo] := SubStr(commandLine, currArgStart, currFragmentEnd - currArgStart - 1) ; excluding last separator
            If (IsObject(separators))
                separators[argNo] := SubStr(commandLine, currFragmentEnd-1, 1)
            
            argNo++
        }
    }
    
    If (inQuote) ; last quote is not properly closed
        cmdlArgs.Push(SubStr(commandLine, currFragmentEnd))
    
    If (IsObject(separators))
        delim := separators
    return cmdlArgs
}
