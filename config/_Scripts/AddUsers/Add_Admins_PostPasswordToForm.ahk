;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
;global debug:=Object()

URL:="https://docs.google.com/forms/d/1moppvJ5WNJAnZrdt5vM5MYJ2IpkL3ZZ7jcyKAaOwJAs/formResponse"
UserName=%1%
FilePath=%2%
EnvGet Status, UserAddError

FileRead data, %FilePath%

RegRead Hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
RegRead Domain, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Domain
If (!Domain)
    RegRead Domain, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, DhcpDomain
If (Domain != "office0.mobilmir" && Domain != "officeVPN.mobilmir")
    Hostname .= "." . Domain

;ToDo: сменить на Trello ID
Random postID, 0, 0xFFFF
postID := A_Now . "#" . Format("{:04x}", postID)

POSTDATA := { "entry.1247228425" : Hostname
	    , "entry.600554004" : UserName
	    , "entry.356325911" : Trim(data, " `n`r`t")
	    , "entry.1306387427" : Status
	    , "entry.1299832479" : postID }

;PostGoogleForm(URL, ByRef kv, tries:=20, retryDelay:=20000)
While (!(success:=PostGoogleForm(URL, POSTDATA, 2, 1000))) {
    If (IsObject(debug)) {
	debugtxt=
	For n,v in debug
	    debugtxt .= n ": " SubStr(v, 1, 100) "`n"
    } Else {
	debugtxt=При отправке произошла ошибка.
    }
    MsgBox 53, Запись %UserName% в таблицу, %debugtxt%`n`n[Попытка %A_Index%`, автоповтор – 5 минут], 300
    IfMsgBox Cancel
	break
}

ExitApp !success

#Include %A_LineFile%\..\..\Lib\PostGoogleForm.ahk
