;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

AddMailbox(ByRef domain, ByRef login, ByRef password, ByRef firstName:="", ByRef lastName:="", ByRef response:="") {
    ;https://tech.yandex.ru/pdd/doc/reference/email-add-docpage/
    ;POST /api2/admin/email/add
    ;Host: pddimp.yandex.ru
    ;PddToken: <ПДД-токен>
    ;...
    ;domain=<имя домена>
    ;&login=<логин почтового ящика>
    ;&password=<пароль>
    POSTDATA := "domain="   . domain
	     . "&login="    . login
	     . "&password=" . password
    
    resa := YandexPddRequest("/api2/admin/email/add", domain, POSTDATA, jsonRespAdd)
    
    respAdd := JSON.Load(jsonRespAdd)
    If (respAdd.uid)
	rese := EditMailbox(domain, respAdd.uid, {iname: firstName, fname: lastName, hintq: "q", hinta: GenPass()}, jsonRespEdit)
    Else
	rese := EditMailbox(domain, "", {login: login, iname: firstName, fname: lastName, hintq: "q", hinta: GenPass()}, jsonRespEdit)
    ;does not find the account if login is numeric -- rese := EditMailbox(domain, login, {iname: firstName, fname: lastName, hintq: "q", hinta: GenPass()}, jsonRespEdit)
    If (IsByRef(response))
	response := Trim(jsonRespAdd, "`n`r`t ") "`t" Trim(jsonRespEdit, "`n`r`t ")
    return resa && rese
}

#include %A_LineNumber%\..\YandexPddRequest.ahk
#include %A_LineNumber%\..\EditMailbox.ahk
#include %A_LineNumber%\..\GenPass.ahk
