;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding CP0

;debug := 1

RunWait C:\SysUtils\wget.exe -N https://pci-ids.ucw.cz/v2.2/pci.ids.bz2,,Min
RunWait "%A_ProgramFiles%\7-Zip\7zG.exe" e pci.ids.bz2 pci.ids
;RunWait C:\SysUtils\wget.exe -N https://github.com/pciutils/pciids/archive/master.zip,,Min
;RunWait "%A_ProgramFiles%\7-Zip\7zG.exe" e master.zip pci.ids

;in:
;# Syntax:
;# vendor  vendor_name
;#	device  device_name				<-- single tab
;#		subvendor subdevice  subsystem_name	<-- two tabs

;0001  SafeNet (wrong ID)
;0010  Allied Telesis, Inc (Wrong ID)
;# This is a relabelled RTL-8139
;	8139  AT-2500TX V3 Ethernet
;001c  PEAK-System Technik GmbH
;	0001  PCAN-PCI CAN-Bus controller
;		001c 0004  2 Channel CAN Bus SJC1000
;		001c 0005  2 Channel CAN Bus SJC1000 (Optically Isolated)
;003d  Lockheed Martin-Marietta Corp

;out:
;0010|8139|NULL|NULL|Allied Telesis, Inc (Wrong ID)|AT-2500TX V3 Ethernet|NULL
;001c|0001|NULL|NULL|PEAK-System Technik GmbH|PCAN-PCI CAN-Bus controller|NULL

nullID := "NULL"
nullName := "NULL"
hex := "[0-9A-Fa-f]"
singleIDRegex := "^(?P<ID>" hex "{4})\s+(?P<Name>.*)"
doubleIDRegex := "^(?P<ID>" hex "{4}\s" hex "{4})\s+(?P<Name>.*)"

dfltLvlIDs	:= {0: nullID, 1: nullID, 2: nullID "|" nullID}
dfltLvlNames	:= {0: nullName, 1: nullName, 2: nullName}
matchRegexes	:= {0: singleIDRegex , 1: singleIDRegex, 2: doubleIDRegex}

maxLvl		:= dfltLvlIDs.MaxIndex()

lvlIDs		:= dfltLvlIDs.Clone()
lvlNames	:= dfltLvlNames.Clone()

prLvl := 0

FileMove pci.db, pci.db.bak
Loop Read, pci.ids, pci.db
{
    unpad := LTrim(A_LoopReadLine)
    If (!StrLen(unpad) || SubStr(unpad, 1, 1) == "#")
	continue
    If (SubStr(unpad, 1, 2) == "C ")
	break
    
    level := StrLen(A_LoopReadLine) - StrLen(unpad)
    
    If (level < prLvl) {
	Loop % maxLvl
	{
	    If (!dfltLvlIDs.HasKey(cl := level+A_Index))
		break
	    lvlIDs[cl]	:= dfltLvlIDs[cl]
	    lvlNames[cl]:= dfltLvlNames[cl]
	}
    }
    
    If (!RegexMatch(unpad, matchRegexes[level], m))
	Throw Exception("Malformed line #" A_Index " in pci.ids",,A_LoopReadLine)
    If (level==maxLvl)
	lvlIDs[level] := StrReplace(mID, " ", "|")
    Else
	lvlIDs[level] := mID
    lvlNames[level] := mName
    
    If (debug) {
	dbg=
	For i,v in lvlIDs {
	    dbg .= "," i ":" v " = " lvlNames[i]
	}
	
	MsgBox % "level: " level "`nmID: " mID "`nmName: " mName "`n" dbg
    }
    
    Loop % maxLvl + 1
	FileAppend % lvlIDs[A_Index-1] "|"
    Loop % maxLvl
	FileAppend % lvlNames[A_Index-1] "|"
    FileAppend % lvlNames[maxLvl] "`n"
    
    prLvl := level
}
