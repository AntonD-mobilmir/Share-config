;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

PostWithProxies(URL,ByRef POSTDATA,tries:=20,retryDelay:=1000) {
    static proxies, lastProxy
    protoFound := RegexMatch(URL, "([^:]{3,6})://", URLproto)
    
    Loop %tries%
    {
        If (lastProxy)
	    Try If (success := WinHttpPOST(URL, POSTDATA, lastProxy))
		return success
        
        If (!proxies) {
            proxies := {}
            ; Очень странно: в Windows 7 префикс протокола ("https://") нужен для отправки через HTTPS, в Windows 10 – наоборот мешает :(
            If (lmProxy := ReadProxy("HKEY_LOCAL_MACHINE"))
                proxies.Push(URLproto . lmProxy, lmProxy)
            If (cuProxy := ReadProxy("HKEY_CURRENT_USER"))
                proxies.Push(URLproto . cuProxy, cuProxy)
            proxies.Push(URLproto . "192.168.127.1:3128", "192.168.127.1:3128", "")
        }
        
	For i,proxy in proxies
	    Try If (success := WinHttpPOST(URL, POSTDATA, proxy))
		return success, lastProxy := proxy
	Sleep retryDelay
    }
    
    return 0
}

;formerly SendWebRequest
WinHttpPOST(URL, POSTDATA, proxy:="") {
    global debug
    static WinHttpRequestObjectName
    If (IsObject(debug))
	FileAppend Отправка через %proxy% на адрес %URL%`nзапроса`n%POSTDATA%`n, **
    If (WinHttpRequestObjectName) {
        WebRequest := ComObjCreate(WinHttpRequestObjectName)
    } Else {
        For i, WinHttpRequestObjectName in ["WinHttp.WinHttpRequest.5.1", "WinHttp.WinHttpRequest"] {
            Try WebRequest := ComObjCreate(WinHttpRequestObjectName)
            If (IsObject(WebRequest))
                break
        }
    }
    WebRequest.Open("POST", URL, false)
    WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    If (proxy!="")
	WebRequest.SetProxy(2,proxy)
    
    Try {
	WebRequest.Send(POSTDATA)
	If (IsObject(debug)) {
	    debug.Headers := WebRequest.GetAllResponseHeaders
	    debug.Response := WebRequest.ResponseText
	    debug.Status := WebRequest.Status	;can be 200, 404 etc., including proxy responses
	    
	    FileAppend % "Статус: " . debug.Status . "`n"
		       . "Заголовки ответа: " . debug.Headers . "`n", **
	}
	return WebRequest.Status >= 200 && WebRequest.Status < 300
    } catch e {
	If (IsObject(debug)) {
	    debug.What:=e.What
	    debug.Message:=e.Message
	    debug.Extra:=e.Extra
	}
	return 0
    } Finally {
	WebRequest := ""
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

ReadProxy(ProxySettingsRegRoot="HKEY_CURRENT_USER") {
    static ProxySettingsIEKey:="Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    RegRead ProxyEnable, %ProxySettingsRegRoot%, %ProxySettingsIEKey%, ProxyEnable
    If ProxyEnable
	RegRead ProxyServer, %ProxySettingsRegRoot%, %ProxySettingsIEKey%, ProxyServer
    return ProxyServer
}

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    tries:=20
    retryDelay:=1000
    debug:=0
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
    ExitApp !PostWithProxies(URL,POSTDATA,tries,retryDelay)
}

EchoWrongArg(arg) {
    FileAppend Неправильный аргумент: %arg%`n, **
}
