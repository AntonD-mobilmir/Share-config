;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

GenPass(len:=20) {
    ;должен содержать от 6 до 20 символов — латинские буквы, цифры или спецсимволы (допускаются знаки ` ! @ # $ % ^ & * ( ) - _ = + [ ] { } ; : " \ | , . < > / ?, не допускаются ~ и ')
    ;& заканчивает поле. Если будет добавлен URIEncode или Base64, можно вернуть
    ;+ , похоже, ломает работу – Яндекс выдает:
    ;Cs+}I%xTG(Rbo8t3]zF9	2017-08-29 test@	{"domain": "k.mobilmir.ru", "success": "error", "error": "badpasswd"}
    ;+:!1.Sj-MWZ>l6;8TMzb	2017-08-29 test@	{"domain": "k.mobilmir.ru", "success": "error", "error": "badpasswd"}
    ;\Y7|rVY/mEX|"c+jQbCK	2017-08-29 test@	{"domain": "rarus.robots.mobilmir.ru", "success": "error", "error": "badpasswd"}
    ;/xVE5-zpl"}rS_.jK2N+	2017-08-29 test1@	{"domain": "rarus.robots.mobilmir.ru", "success": "error", "error": "badpasswd"}
    
    global debug
    static Charset:="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`!@#$%^*()-_=[]{};:\|,.<>/?0123456789"""
	 , CharsetLen:=StrLen(Charset)
    password := ""
    Loop %len%
    {
	Random i,1,%charsetLen%
	password .= SubStr(Charset, i, 1)
    }
    return password
}
