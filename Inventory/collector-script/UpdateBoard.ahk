;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

If (TrelloAPI1(method, req, response, data:="")) {
    
}

ExitApp

#include %A_LineFile%\..\..\..\config\_Scripts\Lib\TrelloAPI1.ahk
