;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
;global debug:=1

RegRead Hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
RegRead Domain, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Domain
IPAddresses=
Loop 4
    If ( A_IPAddress%A_Index%!="0.0.0.0" )
	IPAddresses .= " " . A_IPAddress%A_Index%

If (!configPost) { ; it may be defined when this script is included in "%USERPROFILE%\Dropbox\Developement\TeamViewer\Host\install_script\install.ahk"
    EnvGet configPost, DefaultsSource
    If (!configPost)
	configPost := getDefaultConfig()
    If (configPost)
	configPost .= "\TeamViewer\"
    If %1%
    {    
	configPost=%configPost%%1%
    } Else {
	EnvGet RegConfigName, RegConfigName
	configPost .= RegConfigName
    }
}

getURL("http://freegeoip.net/json/", , reqStatus, geoLocation)

SetRegView 32
Loop {
    RegRead ClientID, HKEY_LOCAL_MACHINE, SOFTWARE\TeamViewer\Version5.1, ClientID
    If (A_Index > 1) {
	TrayTip Сведения об установке TeamViewer, TeamViewer ID отсутствует в реестре`, ожидание…,,1
	Sleep 3000
	TrayTip
    }
} Until ClientID

;entry.1137503626=testhost&entry.1756894160=testid&entry.287789183=testconfig&entry.1477798008=testdept&entry.1221721146=testuser&entry.1999739813=testdesc&fvv=1&draftResponse=%5B%2C%2C%22-2064060711359362913%22%5D%0D%0A&pageHistory=0&fbzx=-2064060711359362913

POSTDATA := "entry.1137503626="  . UriEncode(Hostname)
	  . "&entry.1756894160=" . UriEncode(ClientID)
	  . "&entry.287789183="  . UriEncode(configPost)
	  . "&entry.1477798008=" . UriEncode(Trim(geoLocation, " `t`n"))
	  . "&entry.1221721146=" . UriEncode(A_UserName)
	  . "&entry.1999739813=" . UriEncode(Domain . " " . Trim(IPAddresses))
	  . "&submit=%D0%93%D0%BE%D1%82%D0%BE%D0%B2%D0%BE"

Loop
{
    success := tryPOSTWithProxies("https://docs.google.com/a/mobilmir.ru/forms/d/1Wy8ZFhfnV1VGYN_vHabQvr6Ziy9E9GTbgaua64CcORU/formResponse", POSTDATA)
    
    If (!success)
    {
	MsgBox 53, Сведения об установке TeamViewer, При отправке сведений об установке TeamViewer в таблицу произошла ошибка.`n`n[Попытка %A_Index%`, автоповтор – 5 минут], 300
	IfMsgBox Cancel
	    break
    }
} Until success

ExitApp !success

tryPOSTWithProxies(URL, POSTDATA, ByRef aStatus:=false, ByRef aResponse:="", ByRef aResponseHeaders:="") {
    return ( sendHTTPPOSTRequest(URL, POSTDATA, ReadProxy("HKEY_LOCAL_MACHINE"), aStatus, aResponse, aResponseHeaders)
	  || sendHTTPPOSTRequest(URL, POSTDATA, ReadProxy("HKEY_CURRENT_USER"), aStatus, aResponse, aResponseHeaders)
	  || sendHTTPPOSTRequest(URL, POSTDATA, "192.168.127.1:3128", aStatus, aResponse, aResponseHeaders)
	  || sendHTTPPOSTRequest(URL, POSTDATA, "", aStatus, aResponse, aResponseHeaders) )
}

getURL(URL, proxy="", ByRef aStatus:=false, ByRef aResponse:="", ByRef aResponseHeaders:="") {
    WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    WebRequest.Open("GET", URL, false)
    If (proxy!="")
	WebRequest.SetProxy(2,proxy)
    Try {
	WebRequest.Send()
	aResponseHeaders := WebRequest.GetAllResponseHeaders
	aResponse := WebRequest.ResponseText
	aStatus:=WebRequest.Status	;can be 200, 404 etc., including proxy responses
    } catch e {
	global err
	err:=e
    }
    WebRequest := ""
    If proxy
	proxyText := %A_Space%(over proxy %proxy%)
    FileAppend GET %URL%%proxyText%`n%aStatus%`n%aResponseHeaders%`n%aResponse%,*
}

sendHTTPPOSTRequest(URL, POSTDATA, proxy="", ByRef aStatus:=false, ByRef aResponse:="", ByRef aResponseHeaders:="") {
    global debug

    WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    WebRequest.Open("POST", URL, false)
    WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    If (proxy!="")
	WebRequest.SetProxy(2,proxy)
    Try {
	WebRequest.Send(POSTDATA)
	aResponseHeaders := WebRequest.GetAllResponseHeaders
	aResponse := WebRequest.ResponseText
	aStatus:=WebRequest.Status	;can be 200, 404 etc., including proxy responses
    } catch e {
	err:=e
    }
    WebRequest := ""
    FileAppend POST %URL%`n%aStatus%`n%aResponseHeaders%`n%aResponse%,*
    
    If (debug==1) {
	;http://www.autohotkey.com/board/topic/56987-com-object-reference-autohotkey-l/#entry358974
;	static document
;	Gui Add, ActiveX, w750 h550 vdocument, MSHTML:%aResponse%
;	Gui Show
	
	MsgText := "Over proxy=" . proxy
	    . "`nStatus=" . aStatus
	    . "`nerror:`nWhat=" . err.What
	    . "`nMessage=" . err.Message
	    . "`nExtra=" . err.Extra
	    . "`n`nResponse Headers: " . aResponseHeaders

	MsgBox %MsgText%
    }
    
    If err
	return 0
    Else
	return 1
}

ReadProxy(ProxySettingsRegRoot="HKEY_CURRENT_USER") {
    static ProxySettingsIEKey:="Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    RegRead ProxyEnable, %ProxySettingsRegRoot%, %ProxySettingsIEKey%, ProxyEnable
    If ProxyEnable
	RegRead ProxyServer, %ProxySettingsRegRoot%, %ProxySettingsIEKey%, ProxyServer
    return ProxyServer
}

;GuiClose:
;GuiEscape:
;    ExitApp

;http://www.autohotkey.com/board/topic/75390-ahk-l-unicode-uri-encode-url-encode-function/
; modified from jackieku's code (http://www.autohotkey.com/forum/post-310959.html#310959)
UriEncode(Uri, Enc = "UTF-8")
{
	StrPutVar(Uri, Var, Enc)
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	Loop
	{
		Code := NumGet(Var, A_Index - 1, "UChar")
		If (!Code)
			Break
		If (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
			|| Code >= 0x61 && Code <= 0x7A) ; a-z
			Res .= Chr(Code)
		Else
			Res .= "%" . SubStr(Code + 0x100, -1)
	}
	SetFormat, IntegerFast, %f%
	Return, Res
}

UriDecode(Uri, Enc = "UTF-8")
{
	Pos := 1
	Loop
	{
		Pos := RegExMatch(Uri, "i)(?:%[\da-f]{2})+", Code, Pos++)
		If (Pos = 0)
			Break
		VarSetCapacity(Var, StrLen(Code) // 3, 0)
		StringTrimLeft, Code, Code, 1
		Loop, Parse, Code, `%
			NumPut("0x" . A_LoopField, Var, A_Index - 1, "UChar")
		StringReplace, Uri, Uri, `%%Code%, % StrGet(&Var, Enc), All
	}
	Return, Uri
}

StrPutVar(Str, ByRef Var, Enc = "")
{
	Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
	VarSetCapacity(Var, Len, 0)
	Return, StrPut(Str, &Var, Enc)
}

getDefaultConfigFileName() {
    defaultConfig := getDefaultConfig()
    SplitPath defaultConfig, OutFileName
    return OutFileName
}

getDefaultConfig() {
    EnvGet SystemDrive, SystemDrive
    defaultConfig := ReadSetVarFromBatchFile(A_AppDataCommon . "\mobilmir.ru\_get_defaultconfig_source.cmd", "DefaultsSource")
    If (!defaultConfig)
	defaultConfig := ReadSetVarFromBatchFile(SystemDrive . "\Local_Scripts\_get_defaultconfig_source.cmd", "DefaultsSource")
    return defaultConfig
}

ReadSetVarFromBatchFile(filename, varname) {
    Loop Read, %filename%
    {
	trimmedReadLine:=Trim(A_LoopReadLine)
	If (SubStr(trimmedReadLine, 1, 4) = "SET ") {
	    splitter := InStr(trimmedReadLine, "=")
	    If (splitter && Trim(SubStr(trimmedReadLine, 5, splitter-5), """`t ") = varname) {
		return Trim(SubStr(trimmedReadLine, splitter+1), """`t ")
	    }
	}
    }
}
