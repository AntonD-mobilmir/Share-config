;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8
;global debug:=1

RegRead Hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
RegRead Domain, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Domain
If ({"":"","office0.mobilmir":"","officeVPN.mobilmir":""}.HasKey(Domain))
    Domain=

ahkName=Отправка TeamViewer ID
trelloidlines := ["trelloURL", "trelloHostname", "trelloCardName", "trelloID", "trelloLocation"]
trelloIDpath := A_AppDataCommon "\mobilmir.ru\trello-id.txt"

If (FileExist(trelloIDpath)) {
    Loop Read, %trelloIDpath%
        If (A_LoopReadLine && varName := trelloidlines[A_Index])
            %varName% := A_LoopReadLine
    Until A_Index > trelloidlines.Length()
    If (trelloHostname != Hostname)
        Hostname .= " (trello-id.txt: " trelloHostname ")"
    If (trelloLocation)
        trelloLocation .= " "
}

If (!configPost) { ; it may be defined when this script is included in "%USERPROFILE%\Dropbox\Developement\TeamViewer\Host\install_script\install.ahk"
    EnvGet configPost, DefaultsSource
    If (!configPost)
	Try configPost := getDefaultConfig()
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

TrayTip %ahkName%, Запрос внешнего IP адреса через api.ipify.org
Try extIP := getURL("https://api.ipify.org")
TrayTip

SetRegView 32
Loop {
    If (A_Index > 1) {
        If (A_TimeIdle < 5000)
            TrayTip %ahkName%, TeamViewer ID отсутствует в реестре`, ожидание установки…,,1
	Sleep 3000
	TrayTip
    }

    RegRead ClientID, HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1, ClientID
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
    If (A_TimeIdle < 5000)
        TrayTip %ahkName%, Отправка информации об установке в таблицу Google…,,1
    success := HTTPReq("POST", URL, POSTDATA)
    lastErr := A_LastError
    TrayTip
    If (!success)
    {
        timeoutMsgText := FormatTimeSoon(5, "Minutes")
        If (!MsgBoxWTimeout("При отправке сведений об установке TeamViewer в таблицу произошла ошибка."
                          , "попытка " A_Index "`, автоповтор в ", {base: msgboxpBase, options: 0x35})) ; Retry/Cancel
	    ExitApp lastErr
    }
} Until success

ExitApp !success

; --FlatternAhk-- #include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\MsgBoxWTimeout.ahk
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

MsgBoxWTimeout(text, timeoutName, p := "") {
    ; p is an object with following optional attributes:
    ; title
    ; options := 0x35
    ; timeout := 5
    ; timeoutUnit := "Minutes"
    ; IfMsgBox := {Timeout: 0, Yes: 1, …} strings-to-values mapping
    
    If (!IsObject(p))
        p := {}
    rvMap := p.IfMsgBox ? p.IfMsgBox : {Timeout: -1, Yes: 1, Retry: 1, Continue: 2, TryAgain: 1, Abort: 0, Ignore: -1, Cancel: 0, No: 0}
    
    If (p.timeout)
        timeout := p.timeout, timeoutUnit := p.timeoutUnit ? p.timeoutUnit : "Minutes"
    Else
        timeout := 5, timeoutUnit := "Minutes"
    timeoutMsgText := FormatTimeSoon(timeout, timeoutUnit)
    timeout_s := timeout * {Seconds: 1, Minutes: 60, Hours: 60*60, Days: 24*60*60}[timeoutUnit]
    MsgBox % p.options ? p.options : 0x35, % p.title, %text%`n[%timeoutName%%timeoutMsgText%], %timeout_s%
    IfMsgBox Yes
        return rvMap.Yes
    IfMsgBox No
        return rvMap.No
    IfMsgBox OK
        return rvMap.OK
    IfMsgBox Cancel
        return rvMap.Cancel
    IfMsgBox Abort
        return rvMap.Abort
    IfMsgBox Ignore
        return rvMap.Ignore
    IfMsgBox Retry
        return rvMap.Retry
    IfMsgBox Continue ; [v1.0.44.08+]
        return rvMap.Continue ; [v1.0.44.08+]
    IfMsgBox TryAgain ; [v1.0.44.08+]
        return rvMap.TryAgain ; [v1.0.44.08+]
    IfMsgBox Timeout ; (that is, the word "timeout" is present if the MsgBox timed out)
        return rvMap.Timeout ; (that is, the word "timeout" is present if the MsgBox timed out)
}

; --FlatternAhk-- #include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\FormatTimeSoon.ahk
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

FormatTimeSoon(amount, unit := "Minutes", format := "Time") {
    timeoutMsgVal := ""
    timeoutMsgVal += %amount%, %unit%
    FormatTime timeoutMsgText, %timeoutMsgVal%, %format%
    return timeoutMsgText
}
; --FlatternAhk-- end of: \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\FormatTimeSoon.ahk

; --FlatternAhk-- end of: \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\MsgBoxWTimeout.ahk

; --FlatternAhk-- #include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\URIEncodeDecode.ahk
;http://www.autohotkey.com/board/topic/75390-ahk-l-unicode-uri-encode-url-encode-function/
; modified from jackieku's code (http://www.autohotkey.com/forum/post-310959.html#310959)
UriEncode(Uri, Enc = "UTF-8") {
    Res := ""
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

UriDecode(Uri, Enc = "UTF-8") {
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

StrPutVar(Str, ByRef Var, Enc = "") {
	Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
	VarSetCapacity(Var, Len, 0)
	Return, StrPut(Str, &Var, Enc)
}
; --FlatternAhk-- end of: \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\URIEncodeDecode.ahk

; --FlatternAhk-- #include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\getDefaultConfig.ahk
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

getDefaultConfigFileName(defCfg := -1) {
    If (defCfg==-1)
	defCfg := getDefaultConfig()
    SplitPath defCfg, OutFileName
    return OutFileName
}

getDefaultConfigDir(defCfg := -1) {
    If (defCfg==-1) {
        EnvGet configDir, configDir
	If (configDir)
	    return RTrim(configDir, "\")
	defCfg := getDefaultConfig()
    }
    SplitPath defCfg,,OutDir
    return OutDir
}

getDefaultConfig(batchPath := -1) {
    If (batchPath == -1) {
	EnvGet DefaultsSource, DefaultsSource
	If (DefaultsSource)
	    return DefaultsSource
	Try {
	    return getDefaultConfig(A_AppDataCommon . "\mobilmir.ru\_get_defaultconfig_source.cmd")
	}
	EnvGet SystemDrive, SystemDrive
	return getDefaultConfig(SystemDrive . "\Local_Scripts\_get_defaultconfig_source.cmd")
    } Else {
	return ReadSetVarFromBatchFile(batchPath, "DefaultsSource")
    }
}

; --FlatternAhk-- #include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\ReadSetVarFromBatchFile.ahk
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

ReadSetVarFromBatchFile(filename, varname) {
    Loop Read, %filename%
    {
	If (RegExMatch(A_LoopReadLine, "ASi)[\s()]*SET\s+(?P<Name>.+)\s*=(?P<Value>.+)", m)) {
	    If (Trim(Trim(mName), """") = varname) {
		return Trim(Trim(mValue), """")
	    }
	}
    }
    Throw Exception("Var not found",, varname)
}
; --FlatternAhk-- end of: \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\ReadSetVarFromBatchFile.ahk

; --FlatternAhk-- end of: \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\getDefaultConfig.ahk

; --FlatternAhk-- #include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\GetFingerprint.ahk
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

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
			 , "CPUSocket": "" ; trello.com/c/iqzGJkcI/307, https://trello.com/c/qXdzEAEQ/249
			 , "Manufacturer0": "" ; RAM: Manufacturer0, PartNumber: PartNum0, SerialNumber: SerNum0
			 , "Manufacturer1": ""
			 , "Manufacturer2": "" ; RAM: Manufacturer2, PartNumber: PartNum2, SerialNumber: SerNum2
			 , "Manufacturer3": ""
			 , "Manufacturer00": "" ; RAM: Manufacturer00, PartNumber: HMT125U6TFR8C-H9, SerialNumber: A516521C
			 , "Manufacturer01": "" ; RAM: Manufacturer01, PartNumber: ModulePartNumber01, SerialNumber: SerNum01 https://trello.com/c/8wHwo4SQ/67
			 , "Manufacturer02": ""
			 , "Manufacturer03": ""
			 , "ModulePartNumber00": "" ; https://trello.com/c/HFcgc6Er/236
			 , "ModulePartNumber01": "" ; RAM: Manufacturer01, PartNumber: ModulePartNumber01, SerialNumber: SerNum01 https://trello.com/c/8wHwo4SQ/67
			 , "ModulePartNumber02": ""
			 , "ModulePartNumber03": ""
			 , "SerNum00": "" ; https://trello.com/c/HFcgc6Er/236
			 , "SerNum01": "" ; RAM: Manufacturer01, PartNumber: ModulePartNumber01, SerialNumber: SerNum01 https://trello.com/c/8wHwo4SQ/67
			 , "SerNum02": ""
			 , "SerNum03": ""
			 , "PartNum0": ""
			 , "PartNum1": ""
			 , "PartNum2": ""
			 , "PartNum3": ""
			 , "SerNum0": ""
			 , "SerNum1": ""
			 , "SerNum2": ""
			 , "SerNum3": ""
			 , "Default string": ""
			 , "N/A": ""
			 , "Unknow": ""
			 , "Unknow Unknow Unknow": "" ; https://trello.com/c/uTCFOTJW/77
			 , "Undefined": ""
			 , "None": "" }
    return SkipValues
}

GetFingerprint_CheckVirtualNIC(fieldName, v) {
    static SkipDescriptions := { "RAS Async Adapter": "" ; Виртуальный NIC VPN с одним и тем же MAC на разных системах
			       , "WAN Miniport (IP)": ""
			       , "WAN Miniport (IPv6)": ""
			       , "WAN Miniport (Network Monitor)": ""
			       , "Минипорт WAN (PPTP)": ""
			       , "Microsoft Wi-Fi Direct Virtual Adapter": "" }
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
; --FlatternAhk-- end of: \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\GetFingerprint.ahk

; --FlatternAhk-- #include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\GetURL.ahk
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

; --FlatternAhk-- #include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\HTTPReq.ahk
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

HTTPReq(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef response:=0, ByRef reqmoreHeaders:=0) {
    If (method = "POST") {
        If (reqmoreHeaders==0) {
            moreHeaders := {"Content-Type": "application/x-www-form-urlencoded"}
        } Else If (IsObject(reqmoreHeaders)) {
            If (reqmoreHeaders.HasKey("Content-Type")) {
                moreHeaders := reqmoreHeaders
            } Else {
                moreHeaders := reqmoreHeaders.Clone()
                moreHeaders["Content-Type"] := "application/x-www-form-urlencoded"
            }
        }
    }
    ;ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef response:=0, ByRef moreHeaders:=0
    return XMLHTTP_Request(method, URL, POSTDATA, response, moreHeaders) || WinHTTPReqWithProxies(method, URL, POSTDATA, response, moreHeaders)
}

WinHTTPReqWithProxies(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef response:=0, ByRef moreHeaders:=0, ByRef TryProxies := "") {
    static proxies := ""
    ;URLprotoInURL := RegexMatch(URL, "([^:]{3,6})://", URLproto)
    
    If (!IsObject(proxies)) {
        proxies := {}
        If (IsObject(TryProxies)) {
            HTTPReq_PushMissingItems(proxies, TryProxies)
        } Else If (TryProxies) {
            Loop Parse, TryProxies, `n`r`,
                HTTPReq_PushMissingItems(proxies, [A_LoopField])
        }
            
        HTTPReq_PushMissingItems(proxies, [ ""
                                          , cuProxy := HTTPReq_ReadProxy("HKEY_CURRENT_USER")
                                          , lmProxy := HTTPReq_ReadProxy("HKEY_LOCAL_MACHINE")
                                          , "192.168.127.1:3128" ] )
                                          ; Очень странно: в Windows 7 префикс протокола ("https://") нужен для отправки через HTTPS, в Windows 10 – наоборот мешает :(
        HTTPReq_PushMissingItems(proxies, [ "https://" cuProxy
                                          , "http://" cuProxy
                                          , "https://" lmProxy
                                          , "http://" lmProxy
                                          , "https://192.168.127.1:3128"
                                          , "http://192.168.127.1:3128"] )
    }
    
    For i,proxy in proxies
        Try If (success := WinHttpRequest(method, URL, POSTDATA, response, moreHeaders, proxy))
            return success
    
    return 0
}

HTTPReq_PushMissingItems(ByRef listToAppendTo, listToAppendFrom, ByRef newSetOfAllItems := 0) {
    static setOfAllItems
    If (IsByRef(newSetOfAllItems))
        setOfAllItems := newSetOfAllItems
    If (!IsObject(setOfAllItems))
        For i, v in listToAppendTo
            setOfAllItems[v] := ""
    For i, v in listToAppendFrom
        If (!setOfAllItems.HasKey(v))
            listToAppendTo.Push(v), setOfAllItems[v] := ""
}

HTTPReq_ReadProxy(ProxySettingsRegRoot) {
    static ProxySettingsIEKey:="Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    RegRead ProxyEnable, %ProxySettingsRegRoot%, %ProxySettingsIEKey%, ProxyEnable
    If ProxyEnable
	RegRead ProxyServer, %ProxySettingsRegRoot%, %ProxySettingsIEKey%, ProxyServer
    return ProxyServer
}

; --FlatternAhk-- #include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\XMLHTTP_Request.ahk
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
; --FlatternAhk-- end of: \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\XMLHTTP_Request.ahk

; --FlatternAhk-- #include \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\WinHttpRequest.ahk
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

WinHttpRequest(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef response:=0, ByRef moreHeaders:=0, ByRef proxy:="") {
    global debug
    static WinHttpRequestObjectName
    If (WinHttpRequestObjectName) {
        WebRequest := ComObjCreate(WinHttpRequestObjectName)
    } Else {
        For i, WinHttpRequestObjectName in ["WinHttp.WinHttpRequest.5.1", "WinHttp.WinHttpRequest"] {
            Try WebRequest := ComObjCreate(WinHttpRequestObjectName)
            If (IsObject(WebRequest))
                break
        }
    }
    WebRequest.Open(method, URL, false)
    For name, value in moreHeaders
        WebRequest.SetRequestHeader(name, value)
    ;WebRequest.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    If (proxy)
	WebRequest.SetProxy(2,proxy)
    
    Try {
	WebRequest.Send(POSTDATA)
	st := WebRequest.Status
        If (IsByRef(response)) {
	    response := IsObject(response)
                        ? {status: st, headers: WebRequest.getAllResponseHeaders, responseText: WebRequest.responseText}
                        : WebRequest.ResponseText
	}
	If (IsObject(debug)) {
	    debug.Headers := WebRequest.GetAllResponseHeaders
	    debug.Status := st	;can be 200, 404 etc., including proxy responses
	    
	    If (IsFunc(debug.cbStatus))
                Func(debug.cbStatus).Call( "`nStatus: " debug.Status "`n"
                                         . "Headers: " debug.Headers "`n"
                                         . response "`n")
	}
	
	return st >= 200 && st < 300
    } catch e {
	If (IsObject(debug)) {
	    debug.What := e.What
	    debug.Message := e.Message
	    debug.Extra := e.Extra
            If (IsFunc(debug.cbError))
                Func(debug.cbError).Call(e)
            Else
                Throw e
	}
    } Finally {
	WebRequest := ""
	If (IsObject(debug)) {
	    ;http://www.autohotkey.com/board/topic/56987-com-object-reference-autohotkey-l/#entry358974
	    ;static document
	    ;Gui Add, ActiveX, w750 h550 vdocument, % "MSHTML:" . debug.Response
	    ;Gui Show
	    If (IsFunc(debug.cbStatus))
                Func(debug.cbStatus).Call()
	}
    }
}
; --FlatternAhk-- end of: \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\WinHttpRequest.ahk

; --FlatternAhk-- end of: \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\HTTPReq.ahk

; --FlatternAhk-- end of: \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\config\_Scripts\Lib\GetURL.ahk
