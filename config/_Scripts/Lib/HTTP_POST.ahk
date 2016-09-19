;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

PostWithProxies(URL,ByRef POSTDATA,tries:=20,retryDelay:=20000) {
    protoFound := RegexMatch(URL, "([^:]{3,6})://", URLproto)
    ;MsgBox protoFound: %protoFound%`nURLproto: %URLproto%
    
    proxies := [ URLproto . "192.168.127.1:3128" ]
    If (lmProxy := ReadProxy("HKEY_LOCAL_MACHINE"))
	proxies.Push(URLproto . lmProxy)
    If (cuProxy := ReadProxy("HKEY_CURRENT_USER"))
	proxies.Push(URLproto . cuProxy)
    
    Loop %tries%
    {
	For i,v in proxies
	{
	    Try If (success := SendWebRequest(URL,POSTDATA,v))
		return success
	}
	Sleep retryDelay
    }
    
    return 0
}

SendWebRequest(URL, POSTDATA, proxy:="", debug:=0) {
    If (IsObject(debug)) {
	FileAppend %URL%`n%POSTDATA%`n, *
    }
    WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
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
	}
	return WebRequest.Status >= 200 && WebRequest.Status < 300
    } catch e {
	err:=e
	debug.What:=e.What
	debug.Message:=e.Message
	debug.Extra:=e.Extra
	return 0
    } Finally {
	WebRequest := ""
	If (IsObject(debug)) {
	    ;http://www.autohotkey.com/board/topic/56987-com-object-reference-autohotkey-l/#entry358974
	    ;static document
	    ;Gui Add, ActiveX, w750 h550 vdocument, % "MSHTML:" . debug.Response
	    ;Gui Show
	    For k,v in debug
		FileAppend %k%: %v%`n,*
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
    URL=%1%
    POSTDATA=%2%
    ExitApp !PostWithProxies(URL,POSTDATA)
}
