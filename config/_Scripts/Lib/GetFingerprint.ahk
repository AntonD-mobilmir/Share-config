;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

GetFingerprint(ByRef textfp:=0, ByRef strComputer:=".") {
    ;https://autohotkey.com/board/topic/60968-wmi-tasks-com-with-ahk-l/
    objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")
    
    fpo := Object()
    
    for parmName,WMIQparm in GetWMIQueryParametersforFingerprint() {
	fpo[parmName] := Object()
	query := WMIQparm[1]
	valArray := WMIQparm[2]

	for o in objWMIService.ExecQuery("Select " . valArray . " from " . query) {
	    fplo := Object()
	    If (fpline)
		fpline .= "`n" . parmName . ":"
	    
	    Loop Parse, valArray,`,
	    {
		v := Trim(o[A_LoopField])
		;MsgBox query: %query%`nA_LoopField: %A_LoopField%`, v: %v%
		fplo[A_LoopField] := v
		If (textfp!=0 && v && v!="To be filled by O.E.M." && v!="Base Board Serial Number" && v!="Base Board") {
		    If A_LoopField not in Name,Vendor,Version,Manufacturer,Product,Model,Caption,Description
			fieldCaption := ( fpline ? ", " : "" ) . A_LoopField . ": "
		    Else
			fieldCaption := " "
		    fpline .= fieldCaption . v
		}
	    }
	    fpo[parmName].Push(fplo)
	}
	
	If (textfp!=0) {
	    If (fpline)
		textfp .= parmName . ":" . fpline . "`n"
	    fpline := v := "" 
	    multilineField := 0
	}
    }
    ;CPU: AuthenticAMD AMD E1-1200 APU with Radeon(tm) HD Graphics AMD64 Family 20 Model 2 Stepping 0, ProcessorId: 178BFBFF00500F20, SocketDesignation: Socket FT1
    ;MB: LENOVO Lenovo G585 Основная плата 31900004WIN8 STD SGL, SerialNumber: CB22755629
    ;NIC: [00000001] Realtek PCIe FE Family Controller, MACAddress: 20:89:84:96:90:6E
    ;NIC: [00000002] Qualcomm Atheros AR9485WB-EG Wireless Network Adapter, MACAddress: 24:FD:52:25:49:DC
    ;NIC: [00000003] Microsoft Wi-Fi Direct Virtual Adapter, MACAddress: 16:FD:52:25:49:DC
    ;NIC: [00000004] Bluetooth Device (Personal Area Network), MACAddress: 24:FD:52:25:AB:7A
    ;System: LENOVO 20137 Lenovo G585, IdentifyingNumber: 3145505702862, UUID: AC956B92-BDB3-E211-A30C-20898496906E
    
    return fpo
}

GetWMIQueryParametersforFingerprint() {
    params := { "System" :  [ "Win32_ComputerSystemProduct" ,	"Vendor,Name,Version,IdentifyingNumber,UUID" ]
	      , "MB" :      [ "Win32_BaseBoard" , 	    	"Manufacturer,Product,Name,Model,Version,OtherIdentifyingInfo,PartNumber,SerialNumber" ]
	      , "CPU" :     [ "Win32_Processor" , 	    	"Manufacturer,Name,Caption,ProcessorId,SocketDesignation" ]
	      , "RAM" :	    [ "Win32_PhysicalMemory",		"Manufacturer,PartNumber,SerialNumber"]
	      , "NIC" :     [ "Win32_NetworkAdapter where MACAddress is not null" , "Description,MACAddress" ]
	      , "Storage" : [ "Win32_DiskDrive where InterfaceType<>'USB'" , "Model,InterfaceType,SerialNumber"]}
    return params
}

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
    
    If (outjson)
	TransactWriteout(JSON.Dump(fpo), outjson)
    
    If (outtxt)
	TransactWriteout(textfp, outtxt, encoding, append)
    ExitApp
}

TransactWriteout(ByRef text, ByRef fname := "*", encoding := "UTF-8", append := 0) {
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
