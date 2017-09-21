;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

EditMailbox(ByRef domain, ByRef login, ByRef changes, ByRef response:="") {
    ;https://tech.yandex.ru/pdd/doc/reference/email-edit-docpage/
    ;POST /api2/admin/email/edit
    ;Host: pddimp.yandex.ru
    ;PddToken: <ПДД-токен>
    ;...
    ;domain=<имя домена>
    ;&(login=<email-адрес или логин почтового ящика>|uid=<идентификатор почтового ящика>)
    ;[&password=<новый пароль>]
    ;[&iname=<имя>]
    ;[&fname=<фамилия>]
    ;[&enabled=<статус работы почтового ящика>]
    ;[&birth_date=<дата рождения>]
    ;[&sex=<пол>]
    ;[&hintq=<секретный вопрос>]
    ;[&hinta=<ответ на секретный вопрос>]
    POSTDATA := "domain=" domain
    If login is Integer
	POSTDATA .= "&uid=" login
    Else If (login)
	POSTDATA .= "&login=" login

    For k,v in changes
	POSTDATA .= "&" k "=" v
    
    return YandexPddRequest("/api2/admin/email/edit", domain, POSTDATA, response)
}

#include %A_LineNumber%\..\YandexPddRequest.ahk
