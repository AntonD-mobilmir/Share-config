;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

TrelloAPI1(ByRef method, ByRef req, ByRef response, ByRef data:="") {
    ;req is as in documentation https://developers.trello.com/advanced-reference/member#get-1-members-idmember-or-username-boards
    ;
    ;example:	
    ; req:	/members/me/boards
    ; URL:	https://api.trello.com/1/members/me/boards?key=[application_key]&token=[optional_auth_token]

    static APIkey:=0, authToken:=0
    While (!(APIkey && authToken)) {
	EnvGet LocalAppData,LOCALAPPDATA
	FileRead APIkey, %LocalAppData%\mobilmir.ru\Trello-ahk\APIkey.txt
	If (APIkey) {
	    FileRead authToken, %LocalAppData%\mobilmir.ru\Trello-ahk\authtoken.txt
	    ; get auth token (user auth): https://trello.com/1/authorize?expiration=never&scope=read,write,account&response_type=token&name=AutoHotkey%20Script%2016-05-16&key=<API_key>
	    If (!authToken) {
		Run % "https://trello.com/1/authorize?expiration=never&scope=read,write,account&response_type=token&name=AutoHotkey%20Script%2016-05-16&key=" APIkey
		MsgBox Получите токен доступа для скрипта и запишите в %LocalAppData%\mobilmir.ru\Trello-ahk\authtoken.txt
	    }
	} Else {
	    Run https://trello.com/app-key
	    MsgBox Получите ключ API со страницы https://trello.com/app-key и запишите в %LocalAppData%\mobilmir.ru\Trello-ahk\APIkey.txt
	    ;Please keep your API Secret safe. Because your API Key is public for any client-side applications, we do not currently offer a way to reset it.
	}
    }
    
    If (IsObject(data))
	jsondata := JSON.Dump(data)
    Else
	jsondata := data
    retv := XMLHTTP_Request(method, "https://api.trello.com/1" req (InStr(req, "?") ? "&" : "?") "key=" APIkey "&token=" authToken, jsondata, jsonresp:="")
    If (IsObject(response))
	response := JSON.Load(jsonresp)
    Else
	response := jsonresp
    return retv
}

#include %A_LineFile%\..\JSON.ahk
#include %A_LineFile%\..\XMLHTTP_Request.ahk
