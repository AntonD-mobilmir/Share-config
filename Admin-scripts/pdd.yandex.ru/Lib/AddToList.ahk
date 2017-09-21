;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

AddToList(ByRef domain, ByRef maillist, ByRef subscriber, ByRef response:="") {
    ;https://tech.yandex.ru/pdd/doc/reference/email-ml-subscribe-docpage/
    ;POST 
    ;Host: pddimp.yandex.ru
    ;PddToken: <ПДД-токен>
    ;...
    ;domain=<имя домена>
    ;&(maillist=<email-адрес или логин рассылки>|maillist_uid=<идентификатор рассылки>)
    ;&(subscriber=<email-адрес подписчика>|subscriber_uid=<идентификатор подписчика>)
    ;[&can_send_on_behalf=<статус подписчика>]
    
    POSTDATA := "domain=" domain "&maillist=" maillist "&subscriber=" subscriber
    
    YandexPddRequest("/api2/admin/email/ml/subscribe", domain, POSTDATA, response)
    return
}

#include %A_LineNumber%\..\YandexPddRequest.ahk
