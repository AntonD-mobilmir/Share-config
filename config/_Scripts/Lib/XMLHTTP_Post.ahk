;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

XMLHTTP_PostForm(URL, POSTDATA, ByRef response="") {
    global debug
    If (IsObject(debug)) {
	FileAppend Отправка на адрес %URL% запроса %POSTDATA%`n, **
    }
    XMLHttpRequest := ComObjCreate("Microsoft.XMLHTTP") ; https://msdn.microsoft.com/en-us/library/ms535874.aspx
    ;XMLHttpRequest.open(bstrMethod, bstrUrl, varAsync, varUser, varPassword);
    XMLHttpRequest.open("POST", URL, false)
    XMLHttpRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    Try {
	XMLHttpRequest.send(POSTDATA)
	If (IsObject(response))
	    response := {status: XMLHttpRequest.status, headers: XMLHttpRequest.getAllResponseHeaders, responseText: XMLHttpRequest.responseText}
	If (IsObject(debug)) {
	    debug.Headers := XMLHttpRequest.getAllResponseHeaders
	    debug.Response := XMLHttpRequest.responseText
	    debug.Status := XMLHttpRequest.status	;can be 200, 404 etc., including proxy responses
	    
	    FileAppend % "`tСтатус: " . debug.Status . "`n"
		       . "`tЗаголовки ответа: " . debug.Headers . "`n", **
	}
	return XMLHttpRequest.Status >= 200 && XMLHttpRequest.Status < 300
    } catch e {
	If (IsObject(debug)) {
	    debug.What:=e.What
	    debug.Message:=e.Message
	    debug.Extra:=e.Extra
	}
	return
    } Finally {
	XMLHttpRequest := ""
	If (IsObject(debug)) {
	    ;http://www.autohotkey.com/board/topic/56987-com-object-reference-autohotkey-l/#entry358974
	    ;static document
	    ;Gui Add, ActiveX, w750 h550 vdocument, % "MSHTML:" . debug.Response
	    ;Gui Show
	    For k,v in debug
		FileAppend %k%: %v%`n, **
	}
    }
}

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    tries:=20
    retryDelay:=1000
    global debug
    Loop %0%
    {
	arg:=%A_Index%
	argFlag:=SubStr(arg,1,1)
	If (argFlag=="/" || argFlag=="-") {
	    arg:=SubStr(arg,2)
	    foundPos := RegexMatch(arg, "([^=]+)=(.+)", argkv)
	    If (foundPos) {
		If (argkv1 = "tries") {
		    tries := argkv2
		} Else If (argkv1 = "retryDelay") {
		    retryDelay := argkv2
		} Else {
		    EchoWrongArg(arg)
		}
	    } Else {
		If (arg="debug") {
		    debug := Object()
		    FileAppend Включен режим отладки`n, **
		} Else {
		    EchoWrongArg(arg)
		}
	    }
	} Else If (!URL) {
	    URL:=arg
	} Else If (!POSTDATA) {
	    POSTDATA:=arg
	} Else {
	    EchoWrongArg(arg)
	}
    }
    Loop %tries%
    {
	If (XMLHTTP_PostForm(URL,POSTDATA, response))
	    Exit 0
	sleep %retryDelay%
	response := Object()
    }
    ExitApp response.status
}

EchoWrongArg(arg) {
    FileAppend Неправильный аргумент: %arg%`n, **
}
