;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8
EnvGet RunInteractiveInstalls, RunInteractiveInstalls
If (RunInteractiveInstalls=="0") {
    RunInteractiveInstalls:=0
    EnvGet logFile, logFile
} Else {
    RunInteractiveInstalls:=1
    logFile = %A_Temp%\%A_ScriptName%.%A_Now%.txt
}

boardID := "5732cc3d0a8bee805cab7f11" ; Учёт системных блоков
testCardID := "5739ae07d92e8a1df52e8cf0" ; Проверка, игнорируйте \\test (карточка для проверки скрипта)
FileCreateDir %A_AppDataCommon%\mobilmir.ru
fileID = %A_AppDataCommon%\mobilmir.ru\IDs.txt

RegRead Hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
RegRead NVHostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, NV Hostname
regViewBak := A_RegView
SetRegView 32
RegRead TVID, HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer\Version5.1, ClientID
SetRegView %regViewBak%

hostnameAlts := Object()
hostnameAlts[Hostname] := "Hostname"
If (Hostname != A_ComputerName)
    hostnameAlts[A_ComputerName] := "ComputerName"
If (NVHostname != Hostname)
    hostnameAlts[NVHostname] := "NV Hostname"
fp := GetFingerprint(textfp := "")

nameText := "("
For k,v in hostnameAlts
    nameText .= (A_Index > 1 ? ", " : "") . v ": " k
nameText .= ", TV ID: " TVID ")"
FileAppend %A_Now% Запись в Trello информации о компьютере %nameText%`n%textfp%`n, %logFile%

;FileAppend % JSON.Dump(fp), %A_AppDataCommon%\mobilmir.ru\fingerprint.json

If (FileExist(fileID)) {
    FileReadLine cardID, %fileID%, 2
    card := Object()
    If (!TrelloAPI1("GET", "/cards/" cardID, card))
	ShowError("Ошибка при получении карточки с ID " cardID " из Trello.`n", JSON.Dump(card), A_LastError, 1)
} else {
    Loop
    {
	errText =
	cards := Object()
	matches := Object()
	;--debug--
	If (debug || TrelloAPI1("GET", "/boards/" . boardID . "/cards", cards)) {
	    If (debug) {
		;TrelloAPI1("GET", "/boards/" . boardID . "/cards", jsoncards)
		;FileMove cards.json, cards.json.bak, 1
		;FileAppend %jsoncards%, cards.json
		FileRead jsoncards, cards.json
		cards := JSON.Load(jsoncards)
	    }
	    
	    For k,card in cards {
		cardHostname := ExtractHostnameFromCardName(card.name, cardTVID)
		If (hostnameAlts.HasKey(cardHostname))
		    matches[k] := hostnameAlts[cardHostname]
		If (TVID && TVID==StrReplace(cardTVID, " ")) {
		    If (!matches.HasKey(k))
			matches[k] := Object()
		    matches[k]["TVID"] := "TeamViwer 5.1 ID"
		}
		For i,NIC in fp.NIC {
		    ;If(InStr(card.desc, "MACAddress: " NIC.MACAddress)) {
		    If(InStr(card.desc, NIC.MACAddress)) {
			If (!matches.HasKey(k))
			    matches[k] := Object()
			matches[k]["MAC"] := NIC.MACAddress
			break
		    }
		}
	    }
	    
	    ;nMatches := matches.GetCapacity() - reports more than really
	    nMatches:=0
	    reportMatches =
	    For k,v in matches {
		card := cards[k]
		reportMatches .= card.shortUrl " – """ card.name """ (совпало: " JSON.Dump(v) ")`n"
		nMatches++
	    }
	    If (!nMatches) {
		errText := "Подходящих карточек не найдено."
	    } Else If (nMatches > 1) {
		errText := "Найдено больше одной подходящей карточки."
	    }
	} Else {
	    ShowError("Ошибка при получении списка карточек с доски учета компьютеров Trello.`n", jsoncards, A_LastError)
	    continue
	}

	If (errText) {
	    ShowError(errText "`n" reportMatches, "`nИсправьте доску учета компьютеров.")
	} Else
	    break
    }
    
    cardID := card.id
}

matchMAC:=0
For i,NIC in fp.NIC {
    If(InStr(card.desc, NIC.MACAddress)) { ; "MACAddress: " 
	matchMAC:=1
	break
    }
}

If (matchMAC) {
    FileAppend % "Найдена подходящая карточка: " card.shortUrl "`n", %logFile%
    Loop Parse, textfp, `n
    {
	If (!InStr(card.desc, A_LoopField)) {
	    FileAppend `tВ карточке не найдена строка %A_LoopField% из отпечатка.`n, %logFile%
	    
	    ;static blockCheckRegexp
	    If (!blockCheckRegexp) {
		For s in GetWMIQueryParametersforFingerprint() {
		    blockCheckRegexp .= (A_Index == 1 ? "" : "|") s
		}
		blockCheckRegexp := "(\n+|^)``````\n(?P<text>((" . blockCheckRegexp . "):.+\n)+)``````(\n+|$)"
	    }
	    
	    ; if any absent, get block ````nCPU: …`nSystem: …`n``` , diff it with textfp and save the diff as comment, then replace the description
	    If (startCardDescFP := RegexMatch(card.desc, blockCheckRegexp, cardDescFP)) {
		newDesc := Trim(SubStr(card.desc, 1, startCardDescFP - 1) "`n" SubStr(card.desc, startCardDescFP + StrLen(cardDescFP)), "`n`r")

		commentText =
		Loop Parse, cardDescFPtext, `n
		    If (!InStr(textfp, Trim(A_LoopField)))
			commentText .= A_LoopField "`n"
		If (commentText) {
		    r=
		    If (!TrelloAPI1("POST", "/cards/" cardID "/actions/comments?text=" UriEncode("Из описания удалены строки:`n`n```````n" Trim(commentText, "`n") "`n``````"), r))
			ShowError("Ошибка при добавлении комментария: " r)
		}
	    } Else {
		; ToDo: удалять старое описание
		newDesc := card.desc
	    }
	    newDesc .= "`n`n```````n" textfp "`n``````"
	    r=
	    If (!TrelloAPI1("PUT", "/cards/" cardID "?desc=" UriEncode(newDesc), r))
		ShowError("Ошибка при изменении описания карточки: " r)
	    break
	}
    }
    ;otherwise, all lines from textfp are already in card, nothing to add/update
} Else {
    ShowError("Ни один из MAC-адресов компьютера не указан в карточке " cardID " (" card.shortURL ")",,,1)
}

ExitApp

ExtractHostnameFromCardName(ByRef cardTitle, ByRef mTVID:="") {
    ;https://support.microsoft.com/en-us/help/909264
    ;NetBIOS names: 1-15 chars, cannot use «\/:*?<>|."» - but \ and / must be screened, and " must be doubled
    ;DNS names allowed chars: only A-Za-z0-9- and unicode
    ;DNS names disallowed chars: «,~:!@#$%^&'.){}_ », first char is alplanum

    If (   RegexMatch(cardTitle, "i)(?<!aka)(?<!\\\\)\\\\(?P<Hostname>[a-z\d][a-z\d-]+[a-z\d])([\s.].*\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\)?|$)", m)
        ;|| RegexMatch(cardTitle, "i)(?<!aka)(?<!\\\\)\\\\(?P<Hostname>[^\\\/:*?<>|.""]{1,15})([\s.]\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\)|$)", m)
        || RegexMatch(cardTitle, "i)(?<!aka)(?<!\\\\)\\\\(?P<Hostname>[^\\\/:*?<>|.""]{1,15})([\s.].*\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\)?|$)", m)
        || RegexMatch(cardTitle, "i)^(?P<Hostname>[a-z\d][a-z\d-]+[a-z\d])([\s.].*\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\)?|$)", m)
        ;|| RegexMatch(cardTitle, "i)^(?P<Hostname>[^\\\/:*?<>|.""]{1,15})([\s.]\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\)|$)", m)
        || RegexMatch(cardTitle, "i)^(?P<Hostname>[^\\\/:*?<>|.""]{1,15})([\s.].*\((?P<TVID>\d{3}\W?\d{3}\W?\d{3})\)?|$)", m))
	return mHostname
    return
}

ShowError(text, msg := "", err := 1, fatal := 0) {
    global logFile, RunInteractiveInstalls
    FileAppend %A_Now% %text%`n, %logFile%
    If (!RunInteractiveInstalls)
	ExitApp err
    Run %logFile%
    If (fatal==1)
	fatal := 0x10
    MsgBox % fatal ? fatal : 1, %A_ScriptName%, %errText%%msg%, 300
    If (fatal)
	ExitApp err
    IfMsgBox Cancel
	ExitApp err
}

#include <URIEncodeDecode>
