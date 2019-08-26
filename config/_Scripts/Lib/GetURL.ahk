;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

GetURL(ByRef URL, tries := 20, delay := 3000) {
    While (!HTTPReq("GET", URL,, resp))
	If (A_Index > tries)
	    Throw Exception("Error downloading URL", A_ThisFunc, resp.status)
	Else
	    sleep delay
    
    return resp
}

If (A_LineFile==A_ScriptFullPath) {
    global debug := {}
    Try {
        FileAppend % GetURL(A_Args*), *, CP1
        ExitApp 0
    }
    ExitApp 1
}

#include %A_LineFile%\..\HTTPReq.ahk
