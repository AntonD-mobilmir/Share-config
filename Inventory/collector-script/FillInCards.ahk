;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8
;boardID := "5732cc3d0a8bee805cab7f11" ; Учёт системных блоков
EnvGet RunInteractiveInstalls, RunInteractiveInstalls
If (RunInteractiveInstalls=="0")
    RunInteractiveInstalls:=0
Else
    RunInteractiveInstalls:=1
global stderr := FileOpen("*", "w", "CP1")

Try {
    RunWait "%A_AhkPath%" "%A_ScriptDir%\DumpBoard.ahk"
    FileRead jsoncards, %A_ScriptDir%\..\trello-accounting\board-dump\computer-accounting.json
    cards := JSON.Load(jsoncards)
    
    argc = %0%
    If (argc) {
	query := CommandLineArgs_to_FindTrelloCardQuery(options := Object())
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
	commonprefix := srcDir "\" Hostname " " DateTime 
	options := {log: commonprefix ".log"}
	For fnamesuffix, qParam in SuffixesToQueries {
	    fpath := commonprefix fnamesuffix
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
	    LogError(e, options.log)
	}
    }
}

FillInCard(ByRef query, ByRef options := "", ByRef fp := "") {
    global cards
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
    If (options.log)
	logFile := options.log, logEncoding := ""
    Else
	logfile := "*", logEncoding := "CP1"
    If (!IsObject(lfo := FileOpen(logfile, "a", logEncoding)))
	Throw Exception("Не открылся файл журнала",, logfile)
    lfo.WriteLine("query: " ObjectToText(query) "`nFingerprint: " ObjectToText(fp))
    lastMatch := ExtendedFindTrelloCard(query, cards, nMatches := 0, fp)
    lfo.WriteLine("lastMatch: " ObjectToText(lastMatch))

    If (nMatches==1) {
	For i in lastMatch {
	    card := TrelloAPI1("GET", "/cards/" cards[i].id, Object()) ; card := cards[i].id to save API calls
	    cardID := card.id 
	    If (!cardID)
		Throw Exception("Карточка без ID",,ObjectToText(card))
	    cardDesc := card.desc
	    lfo.WriteLine("Найдена карточка " card.name " <" card.shortUrl "> #" cardID "`n" cardDesc)
	    textfp=
	    If (pathtextfp := options.txt)
		FileRead textfp, %pathtextfp%
	    If ((!textfp || textfp ~= "^\w:\w" ) && IsObject(fp))
		textfp := GetFingerprint_Object_To_Text(fp)
	    Else
		Throw Exception("Текст отпечатка для " card.name " <" card.shortUrl "> не определен, нечего добавлять в карточку.",,ObjectToText(lastMatch))
	    
	    lfo.WriteLine("Текст отпечатка: " textfp)
	    Loop Parse, textfp, `n
	    {
		; Если любой из строк %textfp% нет в карточке, найти блок ````nCPU: …`nSystem: …`n``` , сравнить с %textfp%, отсутствующие в новом %textfp% строки добавить в комментарий и заменить на новый %textfp%
		trimmedfpline := Trim(A_LoopField)
		If (trimmedfpline && !InStr(cardDesc, trimmedfpline)) {
		    lfo.WriteLine("`tВ карточке не найдена строка " trimmedfpline " из отпечатка. Описание карточки будет изменено.")
		    
		    If (blockCheckRegexp=="") {
			For s in GetWMIQueryParametersforFingerprint()
			    blockCheckRegexp .= (A_Index == 1 ? "" : "|") . s ; варианты начала строк
			blockCheckRegexp := "(\n+|^)``````\n+(?P<text>((" . blockCheckRegexp . "):[^\n]+\n+)+)``````\n*"
		    }
		    
		    If (startCardDescFP := RegexMatch(cardDesc, blockCheckRegexp, cardDescFP)) {
			newDesc := Trim(SubStr(cardDesc, 1, startCardDescFP - 1) "`n" SubStr(cardDesc, startCardDescFP + StrLen(cardDescFP)), "`n`r")
			
			tokenizingSeparators = `n`r%A_Space%%A_Tab%`,
			commentText =
			currentPos := 0
			Loop Parse, cardDescFPtext, %tokenizingSeparators%
			{
			    currentPos += StrLen(A_LoopField) + 1
			    If (!InStr(textfp, Trim(A_LoopField)))
				commentText .= A_LoopField SubStr(cardDescFPtext, currentPos, 1)
			}
			commentText := Trim(commentText, tokenizingSeparators)
			lfo.WriteLine("`tК карточке будет добавлен комментарий: " commentText)
			If (commentText)
			    If (!TrelloAPI1("POST", "/cards/" cardID "/actions/comments?text=" UriEncode("Из отпечатка удалены строки:`n`n```````n" Trim(commentText, "`n") "`n``````"), r := ""))
				Throw Exception("Ошибка при добавлении комментария",,r)
		    } Else {
			; ToDo: удалять описание в других форматах (например, отдельностоящая строка с MAC-адресом)
			newDesc := cardDesc
		    }
		    newDesc .= "`n`n```````n" Trim(textfp, "`r`n`t ") "`n``````"
		    lfo.WriteLine("`tНовое описание карточки: " newDesc)
		    If (!TrelloAPI1("PUT", "/cards/" cardID "?desc=" UriEncode(newDesc), r := ""))
			Throw Exception("Ошибка при изменении описания карточки",,r)
		    break
		}
	    } ; runs until first line of textfp missing from cardDesc
	    ;otherwise, all lines from textfp are already in card, nothing to add/update
	}
	lfo.Close()
	return 1
    } Else {
	Throw Exception("Количество подходящих карточек не равно 1",, nMatches ? JSON.Dump(lastMatch) : nMatches)
    }
}

LogError(ByRef msg, ByRef morepaths*) {
    static pathCommonErrorLog := A_ScriptDir "\..\trello-accounting\update-queue\errors.log"
    logTime := A_Now
    If (IsObject(msg))
	text := ObjectToText(msg)
    Else
	text := msg
    
    Try stderr.WriteLine(logTime " " text)
    Try FileGetSize logsize, %pathCommonErrorLog%, M
    If (logsize)
	Try FileMove %pathCommonErrorLog%, %pathCommonErrorLog%.bak, 1
    Try FileAppend %logTime% %text%`n, %pathCommonErrorLog%
    For i, path in morepaths
	Try FileAppend %logTime% %text%`n, %path%
}

ShowError(ByRef text) {
    global RunInteractiveInstalls
    LogError(text)
    
    If (RunInteractiveInstalls)
	MsgBox %text%
    ExitApp 0x100
}

#include %A_ScriptDir%\..\..\config\_Scripts\Lib\FindTrelloCard.ahk
