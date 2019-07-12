;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding CP0
EnvGet SystemDrive, SystemDrive
EnvGet SystemRoot, SystemRoot
EnvGet LocalAppData, LocalAppData
curlexe := SystemRoot "\System32\curl.exe"
wgetexe := SystemDrive "\SysUtils\wget.exe"
If (IsFunc("FindExe"))
    For i,varname in ["curlexe", "wgetexe"]
        %varname% := Func("FindExe").Call(%varname%)

exe7zgInTCdir := LocalAppData "\Programs\Total Commander\PlugIns\wcx\Total7zip"
exe7zgDirs := [A_ProgramFiles "\7-Zip", exe7zgInTCdir]
If (A_Is64bitOS)
    exe7zgDirs.Pushd(exe7zgInTCBasedir "\64")

If (IsFunc("find7zGUIorAny"))
    exe7z := Func("find7zGUIorAny").Call()
If (!exe7z) {
    exe7zgPaths := []
    For i, dir in exe7zgDirs
        exe7zgPaths[i] := dir "\7zG.exe"
    exe7z := FirstExisting(exe7zgPaths*)
}
;debug := 1

If (wgetexe && FileExist(wgetexe))
    RunWait "%wgetexe%" -N https://pci-ids.ucw.cz/v2.2/pci.ids.bz2,,Min
If (curlexe && !FileExist("pci.ids.bz2") && FileExist(curlexe))
    RunWait "%curlexe%" -z pci.ids.bz2 -OR https://pci-ids.ucw.cz/v2.2/pci.ids.bz2,,Min
If (!FileExist("pci.ids.bz2"))
    UrlDownloadToFile https://pci-ids.ucw.cz/v2.2/pci.ids.bz2, pci.ids.bz2
If (!FileExist("pci.ids.bz2"))
    ExitApp 1

RunWait "%exe7z%" e -aoa -y pci.ids.bz2 pci.ids
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

FileCopy pci.db, pci.db.bak
fout := FileOpen("pci.db", "w")
Loop Read, pci.ids
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
	fout.Write(lvlIDs[A_Index-1] "|")
    Loop % maxLvl
	fout.Write(lvlNames[A_Index-1] "|")
    fout.WriteLine(lvlNames[maxLvl])
    
    prLvl := level
}
fout.Close()

FileDelete pci.ids
FileDelete pci.ids.bz2
FileDelete pci.db.bak
ExitApp

FirstExisting(paths*) {
    for index,path in paths
	If (FileExist(path))
	    return path
    
    return
}

#include *i <find7zexe>
#include *i <findexe>
