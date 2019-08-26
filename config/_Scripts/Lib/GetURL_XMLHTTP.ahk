;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

GetURL(ByRef URL, tries := 20, delay := 3000) {
    While (!XMLHTTP_Request("GET", URL,, resp))
	If (A_Index > tries)
	    Throw Exception("Error downloading URL", A_ThisFunc, resp.status)
	Else
	    sleep delay
    
    return resp
}

#include %A_LineFile%\..\XMLHTTP_Request.ahk
