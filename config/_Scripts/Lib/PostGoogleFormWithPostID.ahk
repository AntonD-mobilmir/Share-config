;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

PostGoogleFormWithPostID(ByRef URLs, ByRef kv, ByRef postID:="", ByRef trelloURL:="") {
    static pathTrelloID := A_AppDataCommon "\mobilmir.ru\trello-id.txt"
    For i, v in kv
	If (IsObject(v)) {
	    Loop 2
	    {
		If (A_Index = 2)
		    v := {"": " ", CutTrelloCardURL: "", TrelloCardName: "", Rnd4Hex: "", A_Now: ""}
		splitter := v[""]
		addedID=
		foundKeys := 0
		For idName, idvalue in v {
		    foundKeys := 1
		    If (idName) {
			addedID .= splitter . idvalue
			If (idName=="TrelloUrl") {
			    If (!trelloURL)
				FileReadLine trelloURL, %pathTrelloID%, 1
			    addedID .= trelloURL
			} Else If (idName=="CutTrelloCardURL") {
			    If (!trelloURL)
				FileReadLine trelloURL, %pathTrelloID%, 1
			    addedID .= CutTrelloCardURL(trelloURL)
			} Else If (idName=="TrelloCardName") {
			    If (!trelloCardName)
				FileReadLine trelloCardName, %pathTrelloID%, 3
			    addedID .= trelloCardName
			} Else If (idName=="Rnd4Hex") {
			    Random rnd, 0, 0xFFFF
			    addedID .= Format("{:04x}", rnd)
			} Else If (idName=="A_Now") {
			    addedID .= A_Now
			} Else addedID .= idName
		    }
		}
	    } Until foundKeys
	    kv[i] := SubStr(addedID, 1 + StrLen(splitter))
	}
    
    If (IsObject(URLs)) {
	URL := URLs[1]
	verifyURL := URLs[2]
    } Else
	URL := URLs
    If (SubStr(URL, 1, 4) != "http")
	Throw Exception("URL не указан или указан неверно",,URL)
    Loop
    {
	If (success:=PostGoogleForm(URL, kv, 2, A_Index * 1000)) { ;PostGoogleForm(URL, kv, tries, retryDelay)
	    ;If (verifyURL) {
		;ToDo: загружать verifyURL и проверять, добавилась ли строчка с postID
	    ;}
	    break
	} Else {
	    If (IsObject(debug)) {
		debugtxt=
		For n,v in debug
		    debugtxt .= n ": " SubStr(v, 1, 100) "`n"
	    } Else
		debugtxt=При отправке формы произошла ошибка.
	    MsgBox 53, A_ScriptName, %debugtxt%`n`n[Попытка %A_Index%`, автоповтор – 5 минут], 300
	    IfMsgBox Cancel
		break
	}
    }
    return success
}

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    FileEncoding UTF-8
    kv := Object()
    postIDfieldFound := 0
    Loop %0%
    {
	arg:=%A_Index%
	If (URL) {
	    If (!foundPos := InStr(arg, "="))
		Throw Exception("Не удалось разрбрать параметр на ключ-значение", "([^=]+)=(.+)", arg)
	    lastKey := SubStr(arg, 1, foundPos-1)
	    If (!kv[lastKey] := SubStr(arg, foundPos+1) && !postIDfieldFound)
		kv[lastKey] := Object(), postIDfieldFound := 1 ; first empty value will be used for postID
	} Else
	    URL:=arg
    }
    ExitApp !PostGoogleFormWithPostID(URL,kv)
}

#include %A_LineFile%\..\PostGoogleForm.ahk
#include %A_LineFile%\..\CutTrelloCardURL.ahk
