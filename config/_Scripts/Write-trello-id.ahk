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

boardDumpDirs := [ A_LineFile "\..\..\..\Inventory\collector-script\trello-accounting-board-dump"
	         , A_ScriptDir "\trello-accounting-board-dump"
	         , A_ScriptDir  ]
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

    MACs := Object()
    fp := GetFingerprint(textfp := "")
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
For i, boardDumpDir in boardDumpDirs {
    If (!FileExist(boardDumpDir "\computer-accounting.json") && FileExist(boardDumpDir "\dump.7z") && (exe7z || exe7z := TryCallFunc("find7zexe") || exe7z := TryCallFunc("find7zaexe"))) {
	RunWait %exe7z% x -y -aoa -o"%tmp%" -- "%boardDumpDir%\dump.7z" "computer-accounting.json" "lists.json", %tmp%, Min UseErrorLevel
	boardDumpDir := tmp
    }
    FileRead jsonboard, %boardDumpDir%\computer-accounting.json
    FileRead jsonLists, %boardDumpDir%\lists.json
    If (jsonboard && IsObject(cards := JSON.Load(jsonboard)), jsonLists && (boardlists := JSON.Load(jsonLists)))
	break
}
If (!IsObject(cards)) {
    Throw Exception("Cards didn't load",, boardDumpDir)
    ; fallback: cards := TrelloAPI1("GET", "/boards/" . boardID . "/cards", jsoncards := Object())
    ; fallback: lists := TrelloAPI1("GET", "/boards/" . boardID . "/lists", jsonLists := Object())
}
jsonboard:=jsonLists:=""

If (IsObject(boardlists)) {
    lists := Object()
    For i, list in boardlists
	lists[list.id] := list.name
    boardlists :=
}

For i, match in lastMatch := FindTrelloCard(query, cards, nMatches := 0)
    FileAppend % "Сard " JSON.Dump(cards[i]) " matched with " JSON.Dump(match) "`n", *, CP1
If (fp) { ; по быстрым параметрам карточка не найдена, поиск по серийникам из отпечатка
    While (!nMatches && A_Index <= 2) { ; первая попытка – с заголовками, вторая – без
	noHeaders := A_Index==1 ; change to 2 after debug
	rs := Object()
	; MACAddress are sought before
	For subsys, set in extSearch := { "System" :  { "IdentifyingNumber": "[^:]+", "UUID": "[A-F\-]{36}" }
					, "MB" :      { "SerialNumber": "[^:]+" }
					, "RAM" :     { "SerialNumber": "[^:]+" }
					, "Storage" : { "SerialNumber": "[^:]+" } }
	    For i, kv in fp[subsys]
		For field in set ; ,regex
		    rs[subsys . i " " field] := noHeaders ? "\b" EscapeRegex(kv[field]) "\b" : EscapeRegex(subsys) ":.*" EscapeRegex(field) ": " EscapeRegex(kv[field]) "(?!, \w+: .+)"
	For i, match in lastMatch := FindTrelloCard("", cards, nMatches, rs)
	    FileAppend % "Сard " JSON.Dump(cards[i]) " matched with " JSON.Dump(match) "`n", *, CP1
	    ;MsgBox % "searched " JSON.Dump(rs) ",`ncard " JSON.Dump(cards[i]) " matched with " JSON.Dump(match) "`n"
    }
}

If (writeSavedID) {
    If (nMatches==1) {
	newtxtf := FileOpen(newpathSavedID := pathSavedID ".tmp", "w`n")
	newtxtf.WriteLine(cards[i].url
		   . "`n" (Hostname ? Hostname : ExtractHostnameFromCardName(cards[i].name))
		   . "`n" cards[i].name
		   . "`n" cards[i].id
		   . "`n" lists[cards[i].idList]
		 . "`n`n" JSON.Dump(cards[i]))
	newtxtf.Close()
	If (FileExist(pathSavedID)) {
	    FileReadLine oldurl, %pathSavedID%, 1
	    FileReadLine oldID, %pathSavedID%, 4
	    ;"shortLink":"6D5aO2qM"
	    If (!(CutTrelloCardURL(oldurl, 1) == cards[i].shortLink && oldID == cards[i].id)) {
		newcardname = %pathSavedID%.%A_Now%.txt
		FileMove %newpathSavedID%, %newcardname%
		Run "%A_AhkPath%" "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk" "%A_ProgramData%\mobilmir.ru" "Карточка, найденная для компьютера, отличается ссылкой или ID от уже сохранённой. Найденная карточка записана в %newcardname%, а файл %pathSavedID% остался без изменений."
		ExitApp
	    }
	}
	FileMove %newpathSavedID%, %pathSavedID%, 1
	Run "%A_AhkPath%" "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk" "%pathSavedID%"
    } Else {
	ffc := FileOpen(pathffc := A_Temp "\все найденные карточки " A_Now ".txt", "a`n")
	ffc.WriteLine("Найдено " nMatches " карточ" NumForm(nMatches,"ка","ки","ек") ".`nПараметры строгого поиска: " JSON.Dump(query) "`n" (extSearch ? "Параметры расширенного поиска: " JSON.Dump(extSearch) : "Расширенный поиск не выполнялся") "`n`nИнформация о системе:`n" GetFingerprint_Object_To_Text(fp) "`n`n---")
	For i, match in lastMatch
	    ffc.WriteLine("`nУ карточки " cards[i].name " " cards[i].shortUrl "/" cards[i].idShort "`n`tсовпало " JSON.Dump(match) "`n`t" cards[i].desc)
	ffc.Close()
	Run "%A_AhkPath%" "%A_ScriptDir%\GUI\Write-trello-id-showmsg.ahk" "%pathffc%" "Подходящих карточек: %nMatches% всего"
    }
}
ExitApp nMatches==1 ? 0 : (nMatches==0 ? 1 : nMatches)

TryCallFunc(funcName, optns*) {
    Try return %funcName%(optns*)
}

#include <find7zexe>
#include <JSON>
#include <CutTrelloCardURL>
#include <EscapeRegex>
