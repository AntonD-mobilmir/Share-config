;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
;global debug:=1

RegRead Hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
RegRead Domain, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Domain
If Domain in ,office0.mobilmir,officeVPN.mobilmir
    Domain=

trelloidlines := ["trelloURL", "trelloHostname", "trelloCardName", "trelloID", "trelloLocation"]
Loop Read, %A_AppDataCommon%\mobilmir.ru\trello-id.txt
    If (A_LoopReadLine && varName := trelloidlines[A_Index])
	%varName% := A_LoopReadLine
Until A_Index > trelloidlines.Length()
If (trelloHostname && trelloHostname != Hostname)
    Hostname .= " (trello-id.txt: " trelloHostname ")"
If (trelloLocation)
    trelloLocation .= " "

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

Try extIP := getURL("https://api.ipify.org")
If (!extIP)
    getURLWinHTTP("https://api.ipify.org", , reqStatus, extIP)

SetRegView 32
Loop {
    RegRead ClientID, HKEY_LOCAL_MACHINE, SOFTWARE\TeamViewer\Version5.1, ClientID
    If (A_Index > 1) {
	TrayTip Сведения об установке TeamViewer, TeamViewer ID отсутствует в реестре`, ожидание…,,1
	Sleep 3000
	TrayTip
    }
} Until ClientID

textfp := ""
If (IsFunc("GetFingerprint"))
    Func("GetFingerprint").Call(textfp)
IPAddresses=
Loop 4
    If ( A_IPAddress%A_Index%!="0.0.0.0" )
	IPAddresses .= A_IPAddress%A_Index% . " "

POSTDATA := "entry.1137503626="  . UriEncode(Hostname)
	  . "&entry.1756894160=" . UriEncode(ClientID)
	  . "&entry.287789183="  . UriEncode(configPost)
	  . "&entry.1477798008=" . UriEncode(Trim(trelloLocation . extIP, " `t`n"))
	  . "&entry.1221721146=" . UriEncode(trelloCardName ? trelloCardName : A_UserName)
	  . "&entry.1999739813=" . UriEncode(Trim(trelloURL "`n" Trim(Domain " " IPAddresses) "`n" textfp, " `t`n`r"))
	  . "&submit=%D0%93%D0%BE%D1%82%D0%BE%D0%B2%D0%BE"

URL := "https://docs.google.com/a/mobilmir.ru/forms/d/1Wy8ZFhfnV1VGYN_vHabQvr6Ziy9E9GTbgaua64CcORU/formResponse"

Loop
{
    success := XMLHTTP_Post(URL, POSTDATA) || tryPOSTWithProxies(URL, POSTDATA)
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

getURLWinHTTP(URL, proxy="", ByRef aStatus:=false, ByRef aResponse:="", ByRef aResponseHeaders:="") {
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
    return !err
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

XMLHTTP_Post(ByRef URL, ByRef POSTDATA, ByRef response:=0, ByRef reqmoreHeaders:=0) {
    If (IsObject(reqmoreHeaders)) {
	If (reqmoreHeaders.HasKey("Content-Type")) {
	    moreHeaders := reqmoreHeaders
	} Else {
	    moreHeaders := reqmoreHeaders.Clone()
	    moreHeaders["Content-Type"] := "application/x-www-form-urlencoded"
	}
    } Else {
	moreHeaders := {"Content-Type": "application/x-www-form-urlencoded"}
    }
    return XMLHTTP_Request("POST", URL, POSTDATA, response, moreHeaders)
}

GetURL(ByRef URL, tries := 20, delay := 3000) {
    While (!XMLHTTP_Request("GET", URL,, resp))
	If (A_Index > tries)
	    Throw Exception("Error downloading URL",, resp.status)
	Else
	    sleep delay
    
    return resp
}

XMLHTTP_Request(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef response:=0, ByRef moreHeaders:=0) {
    global debug
    static useObjName:=""
    ;Error at line 13 in #include file "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\XMLHTTP_Post.ahk".

    ;Line Text: local xhr := ComObjCreate(useObjName)
    ;Error: Local variables must not be declared in this function.

    ;The program will exit.
    ;local i, objName, hName, hVal, k, v
    
    If (IsObject(debug)) {
	If (moreHeaders)
	    For i, v in moreHeaders
		txtHeaders .= "`t" i ": " v "`n"
	FileAppend % method " " URL . (POSTDATA ? " ← " POSTDATA : "") ( moreHeaders ? "`n`tHeaders:`n" txtHeaders : "") "`n", **
    }
    If (useObjName) {
	xhr := ComObjCreate(useObjName)
    } Else {
	objNames := [ "Msxml2.XMLHTTP.6.0", "Msxml2.XMLHTTP.3.0", "Msxml2.XMLHTTP", "Microsoft.XMLHTTP" ]
	For i, objName in objNames {
	    ;xhr=XMLHttpRequest
	    If (IsObject(debug))
		FileAppend `tTrying to create object %objName%…
		
	    xhr := ComObjCreate(objName) ; https://msdn.microsoft.com/en-us/library/ms535874.aspx
	    If (IsObject(xhr)) {
		useObjName := objName
		If (IsObject(debug))
		    FileAppend Done!`n, **
		break
	    }
	    If (IsObject(debug))
		FileAppend nope`n, **
	}
	If (!useObjName)
	    Throw "Не удалось создать объект XMLHTTP"
    }
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
	If (IsObject(debug)) {
	    debug.Headers := xhr.getAllResponseHeaders
	    debug.Response := xhr.responseText
	    debug.Status := xhr.status	;can be 200, 404 etc., including proxy responses
	}
	return xhr.Status >= 200 && xhr.Status < 300
    } catch e {
	If (IsObject(debug)) {
	    debug.What:=e.What
	    debug.Message:=e.Message
	    debug.Extra:=e.Extra
	}
	return
    } Finally {
	xhr := ""
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

;#include *i \\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\GetFingerprint.ahk
GetFingerprint(ByRef textfp:=0, ByRef strComputer:=".") {
    static SkipValues := ""
    If (SkipValues == "")
	SkipValues := GetFingerprint_GetForgedValues()
    ;https://autohotkey.com/board/topic/60968-wmi-tasks-com-with-ahk-l/
    objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")
    
    fpo := Object()
    
    For dispnameMC,WMIQparm in GetWMIQueryParametersforFingerprint() {
	query := WMIQparm[1]
	valArray := WMIQparm[2]
	fpo[dispnameMC] := Object()
	txtDataMС=

	For o in objWMIService.ExecQuery("Select " . valArray . " from " . query) {
	    objDataMO := Object()
	    txtDataMO=
	    
	    Loop Parse, valArray,`,
	    {
		v := Trim(o[A_LoopField])
		;"System IdentifyingNumber":"System Serial Number"
		If (v && !SkipValues.HasKey(v)) { ; Поля с этими значениями пропускаются (остальные поля остаются)
		    ; виртуальные NIC не нужны в отпечатке, пропускаются целиком
		    If (dispnameMC == "NIC" && GetFingerprint_CheckVirtualNIC(A_LoopField, v)) {
			objDataMO=
			txtDataMO=
			break 
		    }
		    objDataMO[A_LoopField] := v
		    
		    If (textfp!=0)
			txtDataMO .= GetFingerprint_WMIMgmtObjPropToText(A_LoopField, v, txtDataMO)
		}
	    }
	    If (txtDataMO)
		txtDataMС .= dispnameMC . ":" txtDataMO "`n"
	    If (objDataMO)
		fpo[dispnameMC][A_Index] := objDataMO
	}
	If (textfp!=0 && txtDataMС)
	    textfp .= txtDataMС
    }
    
    return fpo
}

GetFingerprint_GetForgedValues() {
    static SkipValues := { "To be filled by O.E.M.": ""
			 , "Base Board Serial Number": ""
			 , "Base Board": ""
			 , "BSN12345678901234567": ""
			 , "System Product Name": ""
			 , "System manufacturer": ""
			 , "System Version": ""
			 , "System Serial Number": ""
			 , "x.x": ""
			 , "Основная плата": ""
			 , "00000000": "" ; RAM: 8502, PartNumber: 1600LL Series, SerialNumber: 00000000
			 , "1": "" ; System: FOXCONN A6GMV 0A, IdentifyingNumber: 1
			 , "CPUSocket": "" ; trello.com/c/iqzGJkcI/307-кисловодск-вокзальная-kvvz-2-kvvz-ранее-essstcg-2-647550708
			 , "Manufacturer0": "" ; RAM: Manufacturer0, PartNumber: PartNum0, SerialNumber: SerNum0
			 , "Manufacturer1": ""
			 , "Manufacturer2": "" ; RAM: Manufacturer2, PartNumber: PartNum2, SerialNumber: SerNum2
			 , "Manufacturer3": ""
			 , "Manufacturer00": "" ; RAM: Manufacturer00, PartNumber: HMT125U6TFR8C-H9, SerialNumber: A516521C
			 , "PartNum0": ""
			 , "PartNum1": ""
			 , "PartNum2": ""
			 , "PartNum3": ""
			 , "SerNum0": ""
			 , "SerNum1": ""
			 , "SerNum2": ""
			 , "SerNum3": ""
			 , "Default string": ""
			 , "N/A": "" }
    return SkipValues
}

GetFingerprint_CheckVirtualNIC(fieldName, v) {
    static SkipDescriptions := { "RAS Async Adapter": "" ; Виртуальный NIC VPN с одним и тем же MAC на разных системах
			       , "WAN Miniport (IP)": ""
			       , "WAN Miniport (IPv6)": ""
			       , "WAN Miniport (Network Monitor)": ""
			       , "Минипорт WAN (PPTP)": "" }
	 , SkipMACs := { "20:41:53:59:4E:FF": "" ; Виртуальный NIC VPN с одним и тем же MAC на разных системах
		       , "50:50:54:50:30:30": "" ; Минипорт WAN (PPTP)
		       , "33:50:6F:45:30:30": ""} ; https://www.lansweeper.com/forum/yaf_postst6456_Report-Duplicate-MAC-Addresses-lists-same-computer-multiple-times.aspx
			   
    return ( fieldName=="Description" && SkipDescriptions.HasKey(v)
	  || fieldName=="MACAddress" && (   SkipMACs.HasKey(v)
					 || (firstOctet := "0x" SubStr(v, 1, 2)) & 0x2)) ; если второй бит первого октета = 1, это локально-администрируемый MAC адрес, его не может быть у физического адаптера
}

GetFingerprint_Object_To_Text(fpo) {
    t=
    
    paramNames := Object(), paramOrder := Object()
    For dispnameMC,WMIQparm in GetWMIQueryParametersforFingerprint() {
	paramNames[dispnameMC] := Object(), paramOrder[dispnameMC] := Object()
	Loop Parse, % WMIQparm[2],`,
	    paramNames[dispnameMC][A_Index] := A_LoopField, paramOrder[dispnameMC][A_LoopField] := A_Index
    }
    
    ;MsgBox % ObjectToText({paramNames: paramNames, paramOrder: paramOrder})
    
    For dispnameMC, objDataMO in fpo {
	For j, kv in objDataMO {
	    line=
	    If (dispnameMC=="NIC") {
		skipNIC := 0
		For k, v in kv {
		    If (GetFingerprint_CheckVirtualNIC(k, v)) {
			skipNIC := 1
			break
		    }
		}
		If (skipNIC)
		    continue
	    }
	    Loop % paramNames[dispnameMC].Length() ; known
	    {
		k := paramNames[dispnameMC][A_Index]
		v := kv[k]
		If (kv.HasKey(k))
		    line .= GetFingerprint_WMIMgmtObjPropToText(k, v, line)
	    }
	    For k, v in kv
		If (!paramOrder[dispnameMC].HasKey(k)) ; unknown
		    line .= GetFingerprint_WMIMgmtObjPropToText(k, v, line)
	    
	    If (line)
		t .= dispnameMC ":" line "`n"
	}
    }
    return t
}

GetFingerprint_Text_To_Object(t) {
    Throw "Not implemented"
}

GetFingerprint_WMIMgmtObjPropToText(ByRef propName, ByRef propVal, ByRef currLine:="") {
    static SkipValues := ""
    If (SkipValues == "")
	SkipValues := GetFingerprint_GetForgedValues()
    If (propVal=="" || SkipValues.HasKey(propVal))
	return ""
    If propName in Name,Vendor,Version,Manufacturer,Product,Model,Caption,Description
	return " " . propVal
    Else
	return ( currLine ? ", " : " " ) . propName . ": " . propVal
}

GetWMIQueryParametersforFingerprint(ByRef UniqueIDsOnly:=0) {
    ; {group name for management class (prefix for each object) : [query, properties]}
    static qParams :=  { "System" :  [ "Win32_ComputerSystemProduct" ,	"Vendor,Name,Version,IdentifyingNumber,UUID" ]
		       , "MB" :      [ "Win32_BaseBoard" , 	    	"Manufacturer,Product,Name,Model,Version,OtherIdentifyingInfo,PartNumber,SerialNumber" ]
		       , "CPU" :     [ "Win32_Processor" , 	    	"Manufacturer,Name,Caption,ProcessorId,SocketDesignation" ]
		       , "RAM" :     [ "Win32_PhysicalMemory",		"Manufacturer,PartNumber,SerialNumber" ]
		       , "NIC" :     [ "Win32_NetworkAdapter where MACAddress is not null" , "Description,MACAddress" ]
		       , "Storage" : [ "Win32_DiskDrive where InterfaceType<>'USB'" , "Model,InterfaceType,SerialNumber" ] }
    return qParams
}

GetFingerprintTransactWriteout(ByRef text, ByRef fname := "*", encoding := "UTF-8", append := 0) {
    If (SubStr(fname, 1, 1)=="*") {
	append := 1
	If (SubStr(text, 0) != "`n")
	    suffix := "`n"
    }
    If (append) {
	FileAppend %text%%suffix%, %fname%, %encoding%
    } Else {
	tmpfname := fname "#.tmp"
	If (IsObject(of := FileOpen(tmpfname, 1, encoding))) {
	    of.Write(text)
	    of.Close()
	    FileMove %tmpfname%, %fname%, 1
	}
    }
}
