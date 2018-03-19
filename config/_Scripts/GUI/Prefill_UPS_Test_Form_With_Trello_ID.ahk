;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv
FileEncoding UTF-8

trelloids := ""
Try trelloids := ReadTrelloIdFromTxt({url: "", listName: "", cardName: ""})

Run % "https://docs.google.com/forms/d/e/1FAIpQLSex8iIVycc5kJuwjdncYWCy6KonBIqbdW-IY4pA4rV7cxhZsw/viewform?entry.260028223=" UriEncode(CutTrelloCardURL(trelloids.url)) "&entry.1750908018=" UriEncode(trelloids.List) "&entry.1684335929=" UriEncode(IsObject(trelloids) ? trelloids.name : GetHostname())

return

GetHostname() {
    RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
    return hostname
}

#include %A_ScriptDir%\..\Lib\URIEncodeDecode.ahk
#include %A_ScriptDir%\..\Lib\ReadTrelloIdFromTxt.ahk
#include %A_ScriptDir%\..\Lib\CutTrelloCardURL.ahk
