;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

ParseScriptCommandLine(ByRef cmdlPrms:="", ByRef cmdlAhkPath:="", ByRef ahkArgs:="") {
    ; ["]%A_AhkPath%["] [ahkArgs] ["][%A_ScriptDir%\]%A_ScriptName%["] [args]
    ; cmdlAhkPath is overwritten with path to autohotkey in command line (as is)
    ; ahkArgs is overwritten with autohotkey arguments in command line
    ; If IsByRef(cmdlPrms)
    ;     cmdlPrms is overwritten with script arguments as one string
    ;     returns cmdlArgs  – array with all script arguments,
    ;                         with cmdlArgs[""] = number of arguments, and
    ;                         cmdlArgs[0] := script path from command line
    ;     cmdlPrms positive Int → parse and return only specific number of arguments, cmdlPrms will still have all args
    ;     cmdlPrms negative Int → parse and return only specific number of arguments, cmdlPrms will have remaining args
    ; Else
    ;     returns all script parameters as one string (unparsed)
    CommandLine := DllCall( "GetCommandLine", "Str" )
    
    If cmdlPrms is Integer
    {
        cmdlArgs := [], argc := cmdlPrms >= 0 ? -cmdlPrms-1 : cmdlPrms-1
    } Else {
        argsMax := ""
        removeQuotes := cmdlPrms==""""
        If (removeQuotes || IsByRef(cmdlPrms))
            argc := 0, cmdlArgs := []
        Else
            argc := ""
    }
    If (IsByRef(ahkArgs) && !IsObject(ahkArgs))
        ahkArgs := []
    
    inQuote := 0
    currFragmentEnd := 1
    Loop Parse, CommandLine, %A_Space%%A_Tab%
    {
        If (!inQuote)
            currArgStart := currFragmentEnd, argNo++
        currFragmentEnd += StrLen(A_LoopField)+1
        
        outerLoopField := A_LoopField
        Loop Parse, A_LoopField, "
            If (A_Index>1) ; for «"string"», first loop field is empty. If string is at EOL, last too.
                inQuote := !inQuote
        
        If (!inQuote) { ; this substring is not part of quote (starting at currArgStart), or the quote has just ended
            currArg := SubStr(CommandLine, currArgStart, currFragmentEnd - currArgStart)
            
            If (cmdlScriptPath) { ; script name found in cmdline, script args following
                If(argc == "")
                    break
                ; on first entrance, %1% should be = %currArg%
                If (currArg) {
                    cmdlArgs[argc++] := Trim(removeQuotes ? StrReplace(currArg, """") : currArg)
                    If (argc==-1) ; last arg with limited amount of args
                        break
                }
            } Else {
                If (argNo==1) {
                    ;First arg is always AhkPath (dir is optional, for example, if started via cmdline: try «cmd /c ahk.exe script.ahk»; even extension may not be there; also can be partial, repeating ahk-name: «".\script.ahk\ahk.exe\ahk" .\script.ahk\ahk.exe\script.ahk»).
                    cmdlAhkPath := currArg
                } Else {
                    Loop Files, % Trim(currArg,"""" A_Space A_Tab)
                    {
                        If (A_LoopFileLongPath = A_ScriptFullPath) {
                            cmdlScriptPath := currArg
                            If(argc >= 0)
                                cmdlArgs[0] := cmdlScriptPath
                            skipChars := currFragmentEnd ; next char after real script name
                        } Else If (IsObject(ahkArgs)) { ; otherwise it's AutoHotkey args still
                            ahkArgs[argNo] := currArg
                        }
                        break
                    }
                }
            }
        }
    }
    
    cmdlPrms := SubStr(CommandLine, ((argc != "" && argc < 0 && cmdlPrms < 0) ? currFragmentEnd : skipChars))
    If (argc) {
	cmdlArgs[""] := argc
	return cmdlArgs
    } Else
	return cmdlPrms
}
