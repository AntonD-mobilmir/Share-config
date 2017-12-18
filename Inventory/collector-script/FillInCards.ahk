;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#Warn All
#Warn LocalSameAsGlobal, Off
#Warn UseUnsetGlobal, Off
FileEncoding UTF-8
;boardID := "5732cc3d0a8bee805cab7f11" ; Учёт системных блоков
EnvGet RunInteractiveInstalls, RunInteractiveInstalls
If (RunInteractiveInstalls=="0") {
    RunInteractiveInstalls:=0
} Else {
    RunInteractiveInstalls:=1
    logFile = %A_Temp%\%A_ScriptName%.%A_Now%.txt
}

Try {
    RunWait "%A_AhkPath%" "%A_ScriptDir%\DumpBoard.ahk"
    FileRead jsoncards, %A_ScriptDir%\..\trello-accounting\board-dump\computer-accounting.json
    cards := JSON.Load(jsoncards)
    
    argc = %0%
    If (argc) {
	query := CommandLineArgs_to_FindTrelloCardQuery(options := Object())
	If (options.log)
	    logFile := options.log
	If (query || options.HasKey(fp))
	    ExitApp FillInCard(query, options)
    }
    ExitApp ProcessDir(A_ScriptDir "\..\trello-accounting\update-queue") 
} Catch e {
    ShowError(ObjectToText(e))
}
ExitApp -1

ProcessDir(ByRef srcDir) {
    static SuffixesToQueries := {".json": "fp", ".txt": "", " TVID.txt": {1: "TVID:"}, " trello-id.txt": {1: "url:", 4: "/id "}}
	 , nameRegex := "S)^(?P<Hostname>[^ ]+) (?P<DateTime>\d{4}(-\d\d){2} {1,2}\d{5,6}\.\d\d)(?P<Suffix>.*)"

    hostNames := {}
    Loop Files, %srcDir%\*.txt
	If (RegexMatch(A_LoopFileName, nameRegex, m))
	    If (!hostNames.HasKey(mHostname) || hostNames[mHostname] < mDateTime)
		hostNames[mHostname] := mDateTime

    ;nameOnly := SubStr(A_LoopFileName, 1, -StrLen(A_LoopFileExt)-1)
    For Hostname, DateTime in hostNames {
	query := {Hostname: Hostname}
	options := {}
	For fnamesuffix, qParam in SuffixesToQueries {
	    fpath := srcDir "\" Hostname " " DateTime fnamesuffix
	    If (FileExist(fpath)) {
		If (IsObject(qParam)) {
		    lastLine := qParam.MaxIndex()
		    Loop Read, %fpath%
			If (qParam.HasKey(A_Index))
			    query[qParam[A_Index]] := A_LoopReadLine
		    Until A_Index >= lastLine
		} Else
		    options[qParam] := fpath
	    }
	}
	
	Try {
	    If (FillInCard(query, options) == 1)
		FileDelete %srcDir%\%Hostname% *
	    Else
		MsgBox FillInCard returned fail
	} Catch e {
	    ShowError(ObjectToText(e))
	}
    }
}

FillInCard(ByRef query, ByRef options := "", ByRef fp := "") {
    global logFile, cards
    static blockCheckRegexp := ""
    
    If (!IsObject(fp) && pathjsonfp := options.fp) {
	FileRead jsonfp, %pathjsonfp%
	fp := JSON.Load(jsonfp)
    }
    If (cID := options.id) {
	;"idShort":330
	If (cID ~= "^[0-9a-f]{24}$") ; "id":"578e28a308fa5fd1a2cbfaea"
	    cardID := cID
	Else If (FileExist(cID))
	    FileReadLine cardID, %cID%, 4
	Else If (cID ~= "^[^ ]{8}$") ; "shortLink":"bbUOOuFD"
	    query.shortLink := cID
	Else If (cID ~= "^https://trello.com/c/[^ /]{8}$") ; "shortUrl":"https://trello.com/c/bbUOOuFD"
	    query.shortUrl := cID
	Else If (cID ~= "^https://trello.com/c/[^ /]{8}/") ; "url":"https://trello.com/c/bbUOOuFD/330-s1151-2-3-%D0%B2-%D0%B1%D1%83-%D0%BA%D0%BE%D1%80%D0%BF%D1%83%D1%81%D0%B5-mitx-reserve-mitx2"
	    query.url := cID
    }
    
    FileAppend % "query: " ObjectToText(query) "`nFingerprint: " ObjectToText(fp) "`n", %logFile%
    lastMatch := ExtendedFindTrelloCard(query, cards, nMatches := 0, fp)
    FileAppend % "lastMatch: " ObjectToText(lastMatch) "`n", %logFile%
    
    If (nMatches==1) {
	For i in lastMatch {
	    card := TrelloAPI1("GET", "/cards/" cards[i].id, Object()) ; card := cards[i].id to save API calls
	    cardName := card.name " <" card.shortUrl ">"
	    FileAppend Найдена карточка %cardName%`n, %logFile%
	    cardID := card.id 
	    cardDesc := card.desc
	    textfp=
	    If (pathtextfp := options.txt)
		FileRead textfp, %pathtextfp%
	    If ((!textfp || textfp ~= "^\w:\w" ) && IsObject(fp))
		textfp := GetFingerprint_Object_To_Text(fp)
	    Else
		Throw Exception("Текст отпечатка для " card.name " <" card.shortUrl "> не определен, нечего добавлять в карточку.",,ObjectToText(lastMatch))
	    
	    FileAppend cardName: %cardName%`tcardID: %cardID%`ntextfp: %textfp%`ncardDesc: %cardDesc%`n, %logFile%
	    Loop Parse, textfp, `n
	    {
		; Если любой из строк %textfp% нет в карточке, найти блок ````nCPU: …`nSystem: …`n``` , сравнить с %textfp%, отсутствующие в новом %textfp% строки добавить в комментарий и заменить на новый %textfp%
		trimmedfpline := Trim(A_LoopField)
		If (trimmedfpline && !InStr(cardDesc, trimmedfpline)) {
		    FileAppend `tВ карточке не найдена строка %trimmedfpline% из отпечатка.`n, %logFile%
		    
		    If (blockCheckRegexp=="") {
			For s in GetWMIQueryParametersforFingerprint()
			    blockCheckRegexp .= (A_Index == 1 ? "" : "|") . s ; варианты начала строк
			blockCheckRegexp := "(\n+|^)``````\n+(?P<text>((" . blockCheckRegexp . "):[^\n]+\n+)+)``````\n*"
		    }
		    
		    ;FileAppend % ObjectToText(), %logFile%
		    If (startCardDescFP := RegexMatch(cardDesc, blockCheckRegexp, cardDescFP)) {
			newDesc := Trim(SubStr(cardDesc, 1, startCardDescFP - 1) "`n" SubStr(cardDesc, startCardDescFP + StrLen(cardDescFP)), "`n`r")

			commentText =
			Loop Parse, cardDescFPtext, `n
			    If (!InStr(textfp, Trim(A_LoopField)))
				commentText .= A_LoopField "`n"
			FileAppend commentText: %commentText%`n, %logFile%
			If (commentText)
			    If (!TrelloAPI1("POST", "/cards/" cardID "/actions/comments?text=" UriEncode("Из отпечатка удалены строки:`n`n```````n" Trim(commentText, "`n") "`n``````"), r := ""))
				Throw Exception("Ошибка при добавлении комментария",,r)
		    } Else {
			; ToDo: удалять описание в других форматах (например, отдельностоящая строка с MAC-адресом)
			newDesc := cardDesc
		    }
		    newDesc .= "`n`n```````n" textfp "`n``````"
		    FileAppend newDesc: %newDesc%`n, %logFile%
		    If (!TrelloAPI1("PUT", "/cards/" cardID "?desc=" UriEncode(newDesc), r := ""))
			Throw Exception("Ошибка при изменении описания карточки",,r)
		    break
		}
	    } ; runs until first line of textfp missing from cardDesc
	    ;otherwise, all lines from textfp are already in card, nothing to add/update
	}
	return 1
    } Else {
	Throw Exception("Количество подходящих карточек не равно 1",, nMatches ? JSON.Dump(lastMatch) : nMatches)
    }
}

ShowError(text) {
    global logFile, RunInteractiveInstalls
    FileAppend %A_Now% %text%`n, %logFile%
    If (!RunInteractiveInstalls)
	ExitApp 0x100
    MsgBox %text%
}

#include %A_ScriptDir%\..\..\config\_Scripts\Lib\FindTrelloCard.ahk
