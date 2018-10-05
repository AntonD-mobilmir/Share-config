;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.

InteractiveRunAs(runCmdLine := "") {
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    If (RunInteractiveInstalls!="0") {
        If (runCmdLine == "")
            runCmdLine := DllCall( "GetCommandLine", "Str" )
        Run "*RunAs " runCmdLine
    } Else
        Throw Exception("Need to RunAs, but RunInteractiveInstalls=0",-1,A_ThisFunc)
}

If (A_LineFile == A_ScriptName) { ; Invoked stand-alone
    MsgBox % ParseScriptCommandLine()
    Try {
        InteractiveRunAs(ParseScriptCommandLine())
        ExitApp
    } Catch e
        FileAppend e.What ? e.What : 1
}

#include %A_LineFile%\..\ParseScriptCommandLine.ahk
