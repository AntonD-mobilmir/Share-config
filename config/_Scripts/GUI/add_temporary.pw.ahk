;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

pw := Clipboard
If (!pw)
    hide=HIDE
InputBox pw,,,%hide%,,,,,,,%pw%
If (ErrorLevel)
    ExitApp 2

If (!XMLHTTP_Post("https://file.io/", "text=" pw, response := ""))
    ExitApp 1

;{"success":true,"key":"6lL5lq","link":"https://file.io/6lL5lq","expiry":"14 days"}
;https://temporary.pw/?key=6lL5lq
resp := JSON.Load(response)
FileAppend % resp.key "`n" response "`n", *
Clipboard := "https://temporary.pw/?key=" resp.key
MsgBox Ссылка скопирована.
ExitApp 0

#include %A_LineFile%\..\..\Lib\JSON.ahk
#include %A_LineFile%\..\..\Lib\GetPseudoSecrets.ahk
#include %A_LineFile%\..\..\Lib\PostGoogleFormWithPostID.ahk
;#include %A_LineFile%\..\..\Lib\XMLHTTP_Post.ahk
