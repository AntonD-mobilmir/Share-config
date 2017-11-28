;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

;https://redbooth.com/a/#!/projects/59756/tasks/32350056
;https://drive.google.com/a/mobilmir.ru/file/d/0B6JDqImUdYmlejlIRTRWY0JCZjA/view?usp=sharing

#NoEnv
FileEncoding UTF-8
tmp = %A_Temp%\%A_ScriptName%

If (A_ScriptFullPath == A_LineFile) {
    pathSavedID = %A_AppDataCommon%\mobilmir.ru\trello-id.txt
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
    MACs := {}
    For i,NIC in fp.NIC
	MACs[NIC.MACAddress] := NIC.Description
    
    MsgBox % JSON.Dump(FindTrelloCard({ Hostname: hostnameAlts
				      , TVID: TVID
				      , URL: txtshortUrl
				      , MACAddress: MACs }),, nMatches := 0) "`nN=" nMatches
    
    ;RunWait "%A_AhkPath%" /ErrorStdOut "%A_LineFile%\..\..\..\..\Inventory\collector-script\DumpBoard.ahk", %A_LineFile%\..\..\..\..\Inventory\collector-script

    ;If (!(card := TrelloAPI1("GET", "/cards/" cardID, jsoncard := Object())))
    ;    ShowError("Ошибка при получении карточки с ID " cardID " из Trello.`n", jsoncard, A_LastError, 1)
}

FindTrelloCard(ByRef SearchParams, ByRef boardOrPath := "", ByRef nMatches := 0, ByRef allMatches := "") {
    ; SearchParams = {Hostname: {(Hostname): "Hostname"
    ;			      , (Hostname): "NV Hostname", (Hostname): "ComputerName", (Hostname): "Hostname name", …}
    ;		      , TVID: (TVID)
    ;		      , URL: (ShortURL or ID part)
    ;		      , MACAddress: {(MAC): "Adapter name", (MAC): "Adapter name", …}
    ;		      , id: (CardID)
    ;		      , any_other_field_name: {value: "match description", value: "match description", …}, …}
    If (boardOrPath == "") {
	boardOrPath := [ A_LineFile "\..\..\..\..\Inventory\actual\computer-accounting.json.7z"
		       , A_LineFile "\..\..\..\..\Inventory\actual\computer-accounting.json"
		       , A_ScriptDir "\computer-accounting.json"
		       , A_ScriptDir "\computer-accounting.json.7z" ]
    } Else If (!IsObject(boardOrPath))
	boardOrPath := [boardOrPath]
    For i, boardFileOrArc in boardOrPath {
	If (FileExist(boardFileOrArc)) {
	    SplitPath boardFileOrArc, , , OutExtension
	    If (OutExtension != "json") {
		RunWait %exe7z% x -y -aoa -o"%tmp%" -- "%boardFileOrArc%" "computer-accounting.json", %tmp%, Min UseErrorLevel
		boardFileOrArc := tmp "\computer-accounting.json"
	    }
	    FileRead jsonboard, %boardFileOrArc%
	    If (IsObject(cards := JSON.Load(jsonboard)))
		break
	}
    }
    If (!IsObject(cards)) {
	; fallback: cards := TrelloAPI1("GET", "/boards/" . boardID . "/cards", jsoncards := Object())
	Throw Exception("Cards didn't load",, boardFileOrArc)
    }
    
    boardOrPath := cards
    
    For k, card in cards {
	cardTVID := cardHostname := match := ""
	For pName, pData in SearchParams {
	    If (pName == "Hostname") {
		If (!cardHostname)
		    cardHostname := ExtractHostnameFromCardName(card.name, cardTVID)
		MatchKeyNameOrText(match, cardHostname, pData, pName)
	    } Else If (pName == "TVID") {
		If (!cardTVID)
		    cardHostname := ExtractHostnameFromCardName(card.name, cardTVID)
		MatchKeyNameOrText(match, StrReplace(cardTVID, " ", ""), pData, pName)
	    } Else If (pName == "URL") {
		; pData variants:
		; https://trello.com/c/bbUOOuFD/idShort-*
		; https://trello.com/c/bbUOOuFD
		; /c/bbUOOuFD
		; bbUOOuFD
		If (RegexMatch(pData, "^(((((https?://)?trello.com)?/)?c)?/)?c/(?P<urlID>[^/]+)(/(?P<idShort>\d+))?"), m)
		    pData := murlID
		Else If (slashPos := InStr(pData, "/"))
		    pData := SubStr(pData, 1, slashPos-1)

		;"shortUrl":"https://trello.com/c/bbUOOuFD",
		;"url":"https://trello.com/c/bbUOOuFD/330-s1151-2-3-%D0%B2-%D0%B1%D1%83-%D0%BA%D0%BE%D1%80%D0%BF%D1%83%D1%81%D0%B5-mitx-reserve-mitx2"
		If (card.shortUrl == "https://trello.com/c/" pData)
		    AddMatch(match, pName, pData)
		If (card.idShort == midShort)
		    AddMatch(match, "Номер карточки", midShort)
	    } Else If (pName == "MACAddress") {
		;If(InStr(card.desc, "MACAddress: " pData))
		For addrMAC, addrName in pData
		    If (addrMAC && card.desc ~= "i)" StrReplace(StrReplace(addrMAC, "-", "[:-]?"), ":", "[:-]?"))
			AddMatch(match, addrName, addrMAC)
	    } Else
		MatchKeyNameOrText(match, card[pName], pData, pName)
	}
	
	;MsgBox % "cardHostname: " cardHostname "`ncardTVID: " cardTVID "`ncard.idShort: " card.idShort "`ncard.name: " card.name
	
	If (IsObject(match)) {
	    nMatches++
	    If (!IsObject(allMatches))
		allMatches := Object()
	    allMatches[k] := match
	}
    }
    
    If (nMatches)
	return allMatches
}

ExtractHostnameFromCardName(ByRef cardTitle, ByRef mTVID:="") {
    ;https://support.microsoft.com/en-us/help/909264
    ;NetBIOS names: 1-15 chars, cannot use «\/:*?<>|."» - but \ and / must be screened, and " must be doubled
    ;DNS names allowed chars: only A-Za-z0-9- and unicode
    ;DNS names disallowed chars: «,~:!@#$%^&'.){}_ », first char is alplanum
    
    ;test example: Мин.Воды Танк \\mvtnk-k2 mvtnk@ {AthIIX2 220, 2GB DDR2}
    If (   RegexMatch(cardTitle, "i)(?<!aka)(?<!\\\\)\\\\(?P<Hostname>[a-z\d][a-z\d-]+[k]?[a-z\d])(\s+(.*\s)?(\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\))?|$)", m)
        || RegexMatch(cardTitle, "i)(?<!aka)(?<!\\\\)\\\\(?P<Hostname>[^\\\/:*?<>|.""]{1,15})(\s+(.*\s)?(\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\))?|$)", m)
        || RegexMatch(cardTitle, "i)^(?P<Hostname>[a-z\d][a-z\d-]+[a-z\d])(\s+(.*\s)?(\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\))?|$)", m)
        || RegexMatch(cardTitle, "i)^(?P<Hostname>[^\\\/:*?<>|.""]{1,15})(\s+(.*\s)?(\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\))?|$)", m)
        || RegexMatch(cardTitle, "i)^(?P<Hostname>[^\\\/:*?<>|.""]+)(\s.*)?$", m) )
	return mHostname
    mTVID=
    return
}

MatchKeyNameOrText(ByRef match, ByRef text, ByRef pData, ByRef dfltName := "") {
    If (IsObject(pData)) {
	If (pData.HasKey(text))
	    AddMatch(match, dfltName ? dfltName : pData[text], text)
    } Else If (pData = text)
	AddMatch(match, dfltName ? dfltName : text, text)
}

AddMatch(ByRef match, ByRef name, ByRef data := "") {
    If (!IsObject(match))
	match := Object()
    match[name] := data
}

#include %A_LineFile%\..\TrelloAPI1.ahk
#include %A_LineFile%\..\GetFingerprint.ahk
