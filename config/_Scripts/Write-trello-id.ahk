;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

;https://redbooth.com/a/#!/projects/59756/tasks/32350056
;https://drive.google.com/a/mobilmir.ru/file/d/0B6JDqImUdYmlejlIRTRWY0JCZjA/view?usp=sharing

#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

tmp = %A_Temp%\%A_ScriptName%
pathSavedID = %A_AppDataCommon%\mobilmir.ru\trello-id.txt

boardDumps := [ A_LineFile "\..\..\..\Inventory\collector-script\trello-accounting-board-dump\computer-accounting.json.7z"
	      , A_LineFile "\..\..\..\Inventory\collector-script\trello-accounting-board-dump\computer-accounting.json"
	      , A_ScriptDir "\trello-accounting-board-dump\computer-accounting.json"
	      , A_ScriptDir "\trello-accounting-board-dump\computer-accounting.json.7z"
	      , A_ScriptDir "\computer-accounting.json"
	      , A_ScriptDir "\computer-accounting.json.7z" ]

argc=%0%
If (argc) {
    FileEncoding UTF-8
    query := Object()
    Loop %0%
    {
	If (parmName) {
	    parmValue := %A_Index%
	} Else {
	    argv := %A_Index%
	    If (!colon := InStr(argv, ":"))
		Throw Exception("Param name should end with a colon",,argv)
	    parmName := Trim(SubStr(argv, 1, colon-1))
	    parmValue := Trim(SubStr(argv, colon+1)) ; if "", this arg is just a param name, next arg is parm value
	}
	If (parmValue) { 
	    If (query[parmName]) {
		If (!IsObject(query[parmName]))
		    query[parmName] := {query[parmName]: parmName "0"}
		query[parmName][parmValue] := parmName A_Index
	    } Else
		query[parmName] := parmValue
	    parmName=
	}
    }
    FileAppend % JSON.Dump(query) "`n", *, CP1
} Else {
    writeSavedID := 1
    If (FileExist(pathSavedID)) {
	lineVarNames := ["txtshortUrl", "txtID", "oldHostname"]
	Loop Read, %pathSavedID%
	    If (varName := lineVarNames[A_Index])
		%varName% := A_LoopReadLine
    }
    RegRead Hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
    RegRead NVHostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, NV Hostname
    regViewBak := A_RegView
    SetRegView 32
    RegRead TVID, HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1, ClientID
    SetRegView %regViewBak%

    hostnameAlts := {(Hostname): "Hostname"}
    For varName, varTitle in {A_ComputerName: "Computer Name", NVHostname: "NV Hostname", oldHostname: "hostname from trello-id.txt"}
	If (%varName% && Hostname != %varName%)
	    hostnameAlts[%varName%] := varTitle

    fp := GetFingerprint(textfp := "")
    MACs := Object()
    For i,NIC in fp.NIC
	MACs[NIC.MACAddress] := NIC.Description

    query := { Hostname: hostnameAlts
	     , MACAddress: MACs }
    If (txtshortUrl)
	query.URL := txtshortUrl
    If (TVID)
	query.TVID := TVID
}
;RunWait "%A_AhkPath%" /ErrorStdOut "%A_LineFile%\..\..\..\Inventory\collector-script\DumpBoard.ahk", %A_LineFile%\..\..\..\Inventory\collector-script
;If (!(card := TrelloAPI1("GET", "/cards/" cardID, jsoncard := Object())))
;    ShowError("Ошибка при получении карточки с ID " cardID " из Trello.`n", jsoncard, A_LastError, 1)
For i, boardDumpOrArc in boardDumps
    If (FileExist(boardDumpOrArc)) {
	Try {
	    SplitPath boardDumpOrArc, , , OutExtension
	    If (OutExtension != "json" && (exe7z || exe7z := TryCallFunc("find7zexe") || exe7z := TryCallFunc("find7zaexe"))) {
		RunWait %exe7z% x -y -aoa -o"%tmp%" -- "%boardDumpOrArc%" "computer-accounting.json", %tmp%, Min UseErrorLevel
		boardDumpOrArc := tmp "\computer-accounting.json"
	    }
	    FileRead jsonboard, %boardDumpOrArc%
	    If (IsObject(cards := JSON.Load(jsonboard)))
		break
	}
    }
If (!IsObject(cards)) {
    ; fallback: cards := TrelloAPI1("GET", "/boards/" . boardID . "/cards", jsoncards := Object())
    Throw Exception("Cards didn't load",, boardDumpOrArc)
}

For i, match in FindTrelloCard(query, cards, nMatches := 0)
    FileAppend % "Сard " JSON.Dump(cards[i]) " matched with " JSON.Dump(match) "`n", *, CP1

If (writeSavedID) {
    If (nMatches==1) {
	newtxtf := FileOpen(newpathSavedID := pathSavedID ".tmp", "w`n")
	newtxtf.WriteLine(cards[i].url
		   . "`n" ExtractHostnameFromCardName(cards[i].name)
		   . "`n" cards[i].name
		   . "`n" cards[i].id
		 . "`n`n" JSON.Dump(cards[i]))
	newtxtf.Close()
	If (FileExist(pathSavedID)) {
	    FileReadLine oldurl, %pathSavedID%, 1
	    FileReadLine oldID, %pathSavedID%, 4
	    ;"shortLink":"6D5aO2qM"
	    If (!(CutTrelloCardURL(oldurl, 1) == cards[i].shortLink && oldID == cards[i].id)) {
	    } Else {
		FileMove %newpathSavedID%, %pathSavedID%.%A_Now%.txt
		Run %A_AhkPath% "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk" "Карточка, найденная для компьютера, отличается от сохранённой"
		Throw Exception("Карточка, найденная для компьютера, отличается от сохранённой")
	    }
	}
	FileMove %newpathSavedID%, %pathSavedID%, 1
	Run %A_AhkPath% "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk"
    } Else
	Run %A_AhkPath% "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk" "Подходящих карточек: %nMatches%"
}
ExitApp nMatches==1 ? 0 : (nMatches==0 ? 1 : nMatches)

TryCallFunc(funcName, optns*) {
    Try return %funcName%(optns*)
}

#include <find7zexe>
#include <JSON>
#include <CutTrelloCardURL>