;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

;https://redbooth.com/a/#!/projects/59756/tasks/32350056
;https://drive.google.com/a/mobilmir.ru/file/d/0B6JDqImUdYmlejlIRTRWY0JCZjA/view?usp=sharing

ExtendedFindTrelloCard(ByRef query, Byref cards, ByRef nMatches := 0, ByRef fp := "", matchCallback := -1) {
    If (matchCallback==-1)
	matchCallback := Func("ExtendedFindTrelloCard_LogMatches").Bind(["Карточка ", " подошла по параметрам ", "`n", "Выражения расширенного поиска: ", "`n"])
    If (IsObject(fp) && !query.HasKey("MACAddress"))
	FingerprintMACs_to_FindTrelloCardQuery(fp, query)
    
    Loop
    {
	If (A_Index==1)
	    lastMatch := FindTrelloCard(query, cards, nMatches := 0)
	Else If (IsObject(fp)) ; по быстрым параметрам карточка не найдена и есть отпечаток → поиск по серийникам из отпечатка
	    lastMatch := FindTrelloCard("", cards, nMatches, extSearch := FingerprintSNs_to_Regexes(fp, A_Index == 2)) ; первая попытка (A_Index==2) – с заголовками, вторая (A_Index==3) – без
	If (IsFunc(matchCallback))
	    matchCallback.Call(lastMatch, cards, extSearch)
    } Until nMatches || A_Index >= 3
    return lastMatch
}

FindTrelloCard(ByRef SearchParams, ByRef cards, ByRef nMatches := 0, ByRef RegexSearches := "") {
    ; SearchParams = {Hostname: {(Hostname): "Hostname"
    ;			      , (Hostname): "NV Hostname", (Hostname): "ComputerName", (Hostname): "Hostname name", …}
    ;   	      , Hostname: (Hostname) ; alt to previous
    ;		      , TVID: (TVID)
    ;		      , URL: (ShortURL or ID part)
    ;		      , MACAddress: {(MAC): "Adapter name", (MAC): "Adapter name", …}
    ;		      , MACAddress: (MAC) ; alt to previous
    ;		      , id: (CardID)
    ;		      , descSubstr: {substring: "name", substring2: "name", …}
    ;		      , descSubstr: (substring of card.desc) ; alt to previous
    ;		      , any_other_field_name: (value)
    ;		      , any_other_field_name: {value: "match description", value: "match description", …}, …}
    ; key is query, and value is name because there can be duplicate names (and duplicate values), but no duplicate keys (neither reason for duplicate queries)
    allMatches := Object()
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
	    } Else If (pName == "descSubstr") {
		If (IsObject(pData)) {
		    For query, qName in pData
			If (InStr(card.desc, query))
			    AddMatch(match, qName ? qName : query, query)
		} Else If (InStr(card.desc, pData))
		    AddMatch(match, pName, query)
	    } Else
		MatchKeyNameOrText(match, card[pName], pData, pName)
	}
	If (RegexSearches && card.desc) {
	    If (IsObject(RegexSearches)) {
		For pName, pData in RegexSearches
		    If (RegexMatch(card.desc, pData, m))
			AddMatch(match, pName, m)
	    } Else
		If (RegexMatch(card.desc, RegexSearches, m))
		    AddMatch(match, "Шаблон Regex", m)
	}
	
	;MsgBox % "cardHostname: " cardHostname "`ncardTVID: " cardTVID "`ncard.idShort: " card.idShort "`ncard.name: " card.name
	
	If (IsObject(match)) {
	    nMatches++
	    allMatches[k] := match
	}
    }
    
    If (nMatches)
	return allMatches
}

MatchKeyNameOrText(ByRef match, ByRef text, ByRef pData, ByRef dfltName := "") {
    If (IsObject(pData)) {
	If (pData.HasKey(text)) {
	    valName := pData[text]
	    AddMatch(match, valName ? valName : dfltName, text)
	}
    } Else If (pData = text)
	AddMatch(match, dfltName ? dfltName : text, text)
}

AddMatch(ByRef match, ByRef name, ByRef data := "") {
    If (!IsObject(match))
	match := Object()
    match[name] := data
}

FingerprintMACs_to_FindTrelloCardQuery(ByRef fp, ByRef currentQuery:="") {
    If (currentQuery=="")
	currentQuery := Object()
    MACs := Object()
    For i,NIC in fp.NIC
	MACs[NIC.MACAddress] := NIC.Description
    currentQuery.MACAddress := MACs
    return currentQuery
}

FingerprintSNs_to_Regexes(ByRef fp, withHeaders := 1) {
    SNFieldNames := { "IdentifyingNumber": 1, "UUID": 1, "SerialNumber": 1 }
    rs := Object()
    For subsys, devs in fp { ; fp looks like {subsys: [dev1, dev2], subsys2: [dev], …} ; each dev is {key: value, key: value, …}
	For i, kv in devs { ; i = index, kv = data for device/subsys (multiple nics = multiple kvs within single subsys)
	    For field in SNFieldNames
		If kv.HasKey(field)
		    rs[subsys . (i > 1 ? i : "") " " field] := withHeaders ? "m)^" EscapeRegex(subsys) ":[^\r\n]*" EscapeRegex(field) ": " EscapeRegex(kv[field]) "(\b|, )" : "\b" EscapeRegex(kv[field]) "\b"
	}
    }
    
    return rs
}

ExtractSNsFromCardText() {
    Throw Exception("Not implemented", A_LineFile, A_ThisFunc)
    rs := { "IdentifyingNumber": "\w+"
	  , "UUID": "[A-F\-]{36}"
	  , "SerialNumber": "\w+" }
}

ExtendedFindTrelloCard_LogMatches(delimCardMatch, ByRef lastMatch, ByRef cards, ByRef extSearch:="", ByRef path := "", ByRef coding := "") {
    If (path=="") {
	path := "*"
	coding := "CP1"
    }
    
    If (!IsObject(delimCardMatch))
	delimCardMatch := ["", delimCardMatch, "`n", "", "`n"]
    
    If (IsObject(of := FileOpen(path, "a`n", coding))) {
	If (extSearch)
	    of.Write(matchFormatting[4] . extSearch . matchFormatting[5])
	For i, match in lastMatch
	    of.Write(delimCardMatch[1] . JSON.Dump(cards[i]) . delimCardMatch[2] . JSON.Dump(match) . delimCardMatch[3])
	of.Close()
    }
}

#include %A_LineFile%\..\EscapeRegex.ahk
#include %A_LineFile%\..\ExtractHostnameFromTrelloCardName.ahk
#include *i %A_LineFile%\..\JSON.ahk
