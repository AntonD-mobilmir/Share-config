;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    encoding = UTF-8
    outtxt = *
    outjson =
    
    actn := 0
    Loop %0%
    {
	argv := %A_Index%
	If (actn) {
	    If (actn="json")
		outjson := argv
	    If (actn="encoding")
		FileEncoding %argv%
	    Else If (actn="file")
		outtxt := Trim(actn)
	    actn=
	} Else {
	    If (argv == "/append") ; arguments without additional parameter
		append := 1
	    Else If (SubStr(argv,1,1) == "/") ; all arguments with additional parameter are above in «If (actn)» block
		actn := SubStr(argv, 2)
	    Else
		outtxt := argv
	}
    }
    
    fpo := GetFingerprint(textfp)
    
    If (outtxt)
	GetFingerprintTransactWriteout(textfp, outtxt, encoding, append)
    
    If (outjson)
	GetFingerprintTransactWriteout(JSON.Dump(fpo), outjson)
    ExitApp
}

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
			 , "System Serial Number": "" }
    return SkipValues
}

GetFingerprint_CheckVirtualNIC(fieldName, v) {
    static SkipDescriptions := { "RAS Async Adapter": "" ; Виртуальный NIC VPN с одним и тем же MAC на разных системах
			       , "WAN Miniport (IP)": ""
			       , "WAN Miniport (IPv6)": ""
			       , "WAN Miniport (Network Monitor)": "" }
	 , SkipMACs := { "20:41:53:59:4E:FF": "" } ; Виртуальный NIC VPN с одним и тем же MAC на разных системах
			   
    return ( fieldName=="Description" && SkipDescriptions.HasKey(v)
	  || fieldName=="MACAddress" && (   SkipMACs.HasKey(v)
					 || (firstOctet := "0x" SubStr(v, 1, 2)) & 0x2)) ; если второй бит первого октета = 1, это локально-администрируемый MAC адрес, его не может быть у физического адаптера
}

GetFingerprint_Object_To_Text(fpo) {
    t=
    
    paramNames := Object()
    paramOrder := Object()
    For dispnameMC,WMIQparm in GetWMIQueryParametersforFingerprint() {
	paramNames[dispnameMC] := Object()
	paramOrder[dispnameMC] := Object()
	Loop Parse, % WMIQparm[2]
	{
	    paramNames[dispnameMC][A_Index] := A_LoopField
	    paramOrder[dispnameMC][A_LoopField] := A_Index
	}
    }
    
    For dispnameMC, objDataMO in fpo {
	For j, kv in objDataMO {
	    line=
	    
	    Loop % paramNames[dispnameMC].Length() ; known
		If (kv.HasKey(k := paramNames[dispnameMC][A_Index]) && !(dispnameMC=="NIC" && GetFingerprint_CheckVirtualNIC(k, kv)))
		    line .= GetFingerprint_WMIMgmtObjPropToText(k, kv[k], line)
		
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
    If (SkipValues.HasKey(propVal))
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

#include %A_LineFile%\..\JSON.ahk
