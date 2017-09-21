;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

GenPassFullCharset(len:=20) {
    ;должен содержать от 6 до 20 символов — латинские буквы, цифры или спецсимволы (допускаются знаки ` ! @ # $ % ^ & * ( ) - _ = + [ ] { } ; : " \ | , . < > / ?, не допускаются ~ и ')
    static Charset:="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`!@#$%^&*()-_=+[]{};:\|,.<>/?0123456789"""
	 , CharsetLen:=StrLen(Charset)
    Loop %len%
    {
	Random i,1,%charsetLen%
	password .= SubStr(Charset, i, 1)
    }
    return password
}
