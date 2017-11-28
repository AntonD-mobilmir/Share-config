;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

ParseCommandLine(ByRef cmdlPrms:="", ByRef cmdlAhkPath:="", ByRef ahkArgs:="") {
    CommandLine := DllCall( "GetCommandLine", "Str" )
    ; ["]%A_AhkPath%["] [args] ["][%A_ScriptDir%\]%A_ScriptName%["] [args]
    
    inQuote := 0
    currFragmentEnd := 1
    Loop Parse, CommandLine, %A_Space%%A_Tab%
    {
	If (!inQuote) {
	    currArgStart := currFragmentEnd
	    argNo++
	}
	currFragmentEnd += StrLen(A_LoopField)+1
	
	outerLoopField := A_LoopField
	Loop Parse, A_LoopField, "
	{
	    If (A_Index-1) ; for «"string"», first loop field is empty. If string is at EOL, last too.
		inQuote := !inQuote
	}

	If (inQuote) { ; this substring is part of quote (starting at currArgStart)
	    continue
	}
	; Else := If(!inQuote) { ; quote is just over or not started
	currArg := Trim(SubStr(CommandLine, currArgStart, currFragmentEnd - currArgStart))

	If (cmdlScriptPath) { ; script name found in cmdline, script args following
	    If(IsByRef(cmdlPrms)) {
		If(!IsObject(cmdlArgs))
		    cmdlArgs := Object()
		cmdlArgs[argNo] := currArg
	    }
	    ; on first entrance, %1% must be = Trim(currArg; """")
;	    If (currArg="/KillOnExit") {
;		skipChars := currFragmentEnd ; next char after this argument
;	    	global forceExit :=0
;		OnExit("KillUT")
;	    }
	    break ; break in any case, because only first argument after script name needs to be checked
	} Else {
	    If (argNo==1) {
		;First arg is always autohotkey-exe (path optional, for example, if started via cmdline: try «cmd /c ahk.exe script.ahk»; even extension may not be there. Path can be partial, repeating ahk-name: «./ahk.exe/ahk script/ahk/script.ahk»).
		cmdlAhkPath := currArg
	    } Else {
		Loop Files, % Trim(currArg,"""" A_Space A_Tab)
		{
		    If (A_LoopFileLongPath = A_ScriptFullPath) {
			cmdlScriptPath := currArg
			skipChars := currFragmentEnd ; next char after real script name
		    } Else If (IsByRef(ahkArgs)) { ; otherwise it's AutoHotkey args still
			If (!IsObject(ahkArgs))
			    ahkArgs := Object()
			ahkArgs[argNo] := currArg
		    }
		    break
		}
	    }
	}
    }
    
    cmdlPrms := SubStr(CommandLine, skipChars)
    If (IsByRef(cmdlPrms)) {
	return cmdlArgs
    } Else
	return cmdlPrms
}
