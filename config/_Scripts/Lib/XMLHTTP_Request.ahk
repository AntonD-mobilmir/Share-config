;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

XMLHTTP_Request(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef response:=0, ByRef moreHeaders:=0) {
    global debug

    If (IsObject(debug))
	debug.url := URL, debug.method := method, XMLHTTP_Request_DebugMsg(method " " URL . (POSTDATA ? " ← " POSTDATA : "") . ( moreHeaders ? "`n`tHeaders:`n" XMLHTTP_Request_ahk_ObjectToText(moreHeaders) : ""))
    xhr := XMLHTTP_Request_CreateXHRObject()
    ;xhr.open(bstrMethod, bstrUrl, varAsync, varUser, varPassword);
    xhr.open(method, URL, false)
    ;xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    
    If (IsObject(moreHeaders))
	For hName, hVal in moreHeaders
	    xhr.setRequestHeader(hName, hVal)
    
    Try {
	xhr.send(POSTDATA)
	If (IsObject(response))
	    response := {status: xhr.status, headers: xhr.getAllResponseHeaders, responseText: xhr.responseText}
	Else If (IsByRef(response))
	    response := xhr.responseText
	If (IsObject(debug))
	    For debugField, xhrField in {Headers: "getAllResponseHeaders", Response: "responseText", Status: "status"} ; status can be 200, 404 etc., including proxy responses
		debug[debugField] := xhr[xhrField]
	return xhr.Status >= 200 && xhr.Status < 300
    } catch e {
	If (IsObject(debug))
	    debug.e := e
	return
    } Finally {
	xhr := ""
	If (IsObject(debug)) {
	    XMLHTTP_Request_DebugMsg(debug)
	    ;http://www.autohotkey.com/board/topic/56987-com-object-reference-autohotkey-l/#entry358974
	    ;static document
	    ;Gui Add, ActiveX, w750 h550 vdocument, % "MSHTML:" . debug.Response
	    ;Gui Show
	}
    }
}

XMLHTTP_Request_CreateXHRObject() {
    global debug
    static useObjName:=""

    If (useObjName) {
	return ComObjCreate(useObjName)
    } Else {
	errLog=
	For i, objName in ["Microsoft.XMLHTTP", "Msxml2.XMLHTTP", "Msxml2.XMLHTTP.6.0", "Msxml2.XMLHTTP.3.0"] {
	    ;xhr=XMLHttpRequest
	    If (IsObject(debug))
		debug.XMLHTTPObjectName := objName, XMLHTTP_Request_DebugMsg("`tTrying to create object " objName "…")
		
	    xhr := ComObjCreate(objName) ; https://msdn.microsoft.com/en-us/library/ms535874.aspx
	    If (IsObject(xhr)) {
		useObjName := objName
		If (IsObject(debug))
		    XMLHTTP_Request_DebugMsg("Done!")
		return xhr
	    } Else {
		errLog .= objName ": " A_LastError "`n"
	    }
	    If (IsObject(debug))
		XMLHTTP_Request_DebugMsg("nope")
	}
	If (!useObjName)
	    Throw Exception("Не удалось создать объект XMLHTTP", A_LineFile ":" A_ThisFunc, SubStr(errLog, 1, -1))
    }
}

XMLHTTP_Request_DebugMsg(ByRef text) {
    static outMethod := -1, outf
    If (outMethod == -1) {
	For i, fname in [A_Temp "\" A_ScriptName ".debug." A_Now ".log", "**", "*"]
	    Try outf := FileOpen(fname, "w")
	Until IsObject(outf)
	outMethod := IsObject(outf)
    }
    
    If (outMethod)
	out.WriteLine((IsObject(text) ? XMLHTTP_Request_ahk_ObjectToText(text) : text))
    Else
	MsgBox % A_ScriptName ": " A_LineFile ": " A_ThisFunc "`n" (IsObject(text) ? XMLHTTP_Request_ahk_ObjectToText(text) : text)
}

XMLHTTP_Request_ahk_ObjectToText(obj) {
    out := ""
    For i,v in obj
	out .= i ": " ( IsObject(v) ? "(" XMLHTTP_Request_ahk_ObjectToText(v) ")" : (InStr(v, ",") ? """" v """" : v) ) ", "
    return SubStr(out, 1, -2)
}
