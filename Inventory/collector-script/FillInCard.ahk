;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8
EnvGet RunInteractiveInstalls, RunInteractiveInstalls
If (RunInteractiveInstalls=="0") {
    RunInteractiveInstalls:=0
} Else {
    RunInteractiveInstalls:=1
    logFile = %A_Temp%\%A_ScriptName%.%A_Now%.txt
}

boardID := "5732cc3d0a8bee805cab7f11" ; Учёт системных блоков

FileRead jsoncards, %A_ScriptDir%\..\trello-accounting\board-dump\computer-accounting.json
cards := JSON.Load(jsoncards)

query := CommandLineArgs_to_FindTrelloCardQuery(options := Object())
If (pathjsonfp := options.fp) {
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
    FileRead jsonfp, %pathjsonfp%
    fp := JSON.Load(jsonfp)
}

lastMatch := ExtendedFindTrelloCard(query, cards, nMatches := 0, fp)

If (nMatches==1) {
    For i in lastMatch {
	card := TrelloAPI1("GET", "/cards/" cards[i].id) ; card := cards[i].id to save API calls
	cardName := card.name " <" card.shortUrl ">"
	;MsgBox Найдена подходящая карточка: %cardName%
	FileAppend Найдена карточка %cardName%`n, %logFile%
	cardID := card.id 
	;cardID := "5739ae07d92e8a1df52e8cf0" ; Проверка, игнорируйте \\test (карточка для проверки скрипта)
	cardDesc := card.desc
	If (pathtextfp := options.txt)
	    FileRead textfp, %pathtextfp%
	Else If (IsObject(fp))
	    testfp := GetFingerprint_Object_To_Text(fp)
	Else
	    Throw Exception("Отпечаток для " card.name " <" card.shortUrl "> не указан, нечего добавлять в карточку.")
	
	Loop Parse, textfp, `n
	{
	    ; Если любой из строк %textfp% нет в карточке, найти блок ````nCPU: …`nSystem: …`n``` , сравнить с %textfp%, отсутствующие в новом %textfp% строки добавить в комментарий и заменить на новый %textfp%
	    trimmedfpline := Trim(A_LoopField)
	    If (trimmedfpline && !InStr(cardDesc, trimmedfpline)) {
		FileAppend `tВ карточке не найдена строка %trimmedfpline% из отпечатка.`n, %logFile%
		
		;static blockCheckRegexp
		If (!blockCheckRegexp) {
		    For s in GetWMIQueryParametersforFingerprint()
			blockCheckRegexp .= (A_Index == 1 ? "" : "|") . s ; варианты начала строк
		    blockCheckRegexp := "(\n+|^)``````\n+(?P<text>((" . blockCheckRegexp . "):[^\n]+\n+)+)``````\n*"
		}
		
		MsgBox cardDesc: %cardDesc%`nblockCheckRegexp: %blockCheckRegexp%
		If (startCardDescFP := RegexMatch(cardDesc, blockCheckRegexp, cardDescFP)) {
		    newDesc := Trim(SubStr(cardDesc, 1, startCardDescFP - 1) "`n" SubStr(cardDesc, startCardDescFP + StrLen(cardDescFP)), "`n`r")

		    commentText =
		    Loop Parse, cardDescFPtext, `n
			If (!InStr(textfp, Trim(A_LoopField)))
			    commentText .= A_LoopField "`n"
		    If (commentText)
			If (!TrelloAPI1("POST", "/cards/" cardID "/actions/comments?text=" UriEncode("Из отпечатка удалены строки:`n`n```````n" Trim(commentText, "`n") "`n``````"), r := ""))
			    ShowError("Ошибка при добавлении комментария: " r)
		} Else {
		    ; ToDo: удалять описание в других форматах (например, отдельностоящая строка с MAC-адресом)
		    newDesc := cardDesc
		}
		newDesc .= "`n`n```````n" textfp "`n``````"
		If (!TrelloAPI1("PUT", "/cards/" cardID "?desc=" UriEncode(newDesc), r := ""))
		    ShowError("Ошибка при изменении описания карточки: " r)
		break
	    }
	}
	;otherwise, all lines from textfp are already in card, nothing to add/update
    }
} Else {
    Throw Exception("Количество подходящих карточек не равно 1",, nMatches ? JSON.Dump(lastMatch) : nMatches)
}
ExitApp

ShowError(text) {
    global logFile, RunInteractiveInstalls
    FileAppend %A_Now% %text%`n, %logFile%
    If (!RunInteractiveInstalls)
	ExitApp err
    MsgBox %text%
    ExitApp err
}

#include %A_ScriptDir%\..\..\config\_Scripts\Lib\FindTrelloCard.ahk
