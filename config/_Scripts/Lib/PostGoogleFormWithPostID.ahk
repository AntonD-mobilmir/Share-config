﻿;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

PostGoogleFormWithPostID(ByRef URLs, ByRef kv) {
    ; (, ByRef postID:="", ByRef trelloURL:="") {
    
    ; URLs : 	"https://form_address"
    ;	or	["https://form_address", "https://verify_sheet_address"]
    ; kv: 	{ form_field_with_IDs: ExpandPostIDs_query [, form_field: value [, form_field2: value2 [, …]]] }
    ;
    ;   ExpandPostIDs_query is { [idFuncName: "prefix" [, idFuncName: "prefix" [, …]]] }
    ;	  idFuncNames are queries from %A_LineFile%\..\ExpandPostIDs.ahk or quoted func names,
    ;     prefix is any text.
    
    For i, v in kv
	If (IsObject(v))
	    kv[i] := ExpandPostIDs(v)
    
    If (IsObject(URLs)) {
	URL := URLs[1]
	verifyURL := URLs[2]
    } Else
	URL := URLs
    If (!(SubStr(URL, 1, 8) == "https://" || SubStr(URL, 1, 7) == "http://"))
	Throw Exception("URL должен начинаться с http:// или https://",,URL)
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
	    MsgBox 53, %A_ScriptName%, %debugtxt%`n`n[Попытка %A_Index%`, автоповтор – 5 минут], 300
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
#include %A_LineFile%\..\ExpandPostIDs.ahk
